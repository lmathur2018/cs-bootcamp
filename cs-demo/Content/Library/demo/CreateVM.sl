namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username:
        default: "Capa1\\1285-capa1user"
        required: false
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Lakshmi
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: "${'lakshmi-' + uuid}"
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
            - prefix_list: null
        publish:
          - id: '${new_string}'
          - prefix_list
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: 10.0.46.10
              - user: "Capa1\\1285-capa1user"
              - password:
                  value: Automation123
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: Ubuntu
              - datacenter: Capa1 Datacenter
              - vm_name: '${prefix + id}'
              - vm_folder: Students/Lakshmi
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix + id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: on_failure
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix + id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 96
        y: 79
        navigate:
          87d42490-7b35-bf93-6dbe-ec108826ed62:
            vertices:
              - x: 197
                y: 134
            targetId: substring
            port: SUCCESS
      substring:
        x: 348
        y: 165
      clone_vm:
        x: 566
        y: 277
      power_on_vm:
        x: 691
        y: 206
      wait_for_vm_info:
        x: 742
        y: 81
        navigate:
          8097b27d-1dd0-789f-d674-cf617b3b2e9d:
            targetId: 26ab6ae3-752f-6554-d266-52606510a5d2
            port: SUCCESS
    results:
      SUCCESS:
        26ab6ae3-752f-6554-d266-52606510a5d2:
          x: 564
          y: 99
