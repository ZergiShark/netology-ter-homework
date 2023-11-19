## Задание 1

![screenshot](/screenshots/securty_group.png)

## Задание 2

[for_each-vm.tf](/src/for_each-vm.tf) 
[count-vm.tf](/src/count-vm.tf)
### Создание виртуальных машин:
```
yandex_compute_instance.web[0]: Creating...
yandex_compute_instance.web[1]: Creating...
yandex_compute_instance.web[0]: Still creating... [10s elapsed]
yandex_compute_instance.web[1]: Still creating... [10s elapsed]
yandex_compute_instance.web[0]: Still creating... [20s elapsed]
yandex_compute_instance.web[1]: Still creating... [20s elapsed]
yandex_compute_instance.web[0]: Still creating... [30s elapsed]
yandex_compute_instance.web[1]: Still creating... [30s elapsed]
yandex_compute_instance.web[0]: Still creating... [40s elapsed]
yandex_compute_instance.web[1]: Still creating... [40s elapsed]
yandex_compute_instance.web[0]: Creation complete after 43s [id=fhm9cp3ots2upcij98tp]
yandex_compute_instance.web[1]: Creation complete after 44s [id=fhmujg2so4dknupd68lu]
yandex_compute_instance.fe_instance["vm-2"]: Creating...
yandex_compute_instance.fe_instance["vm-1"]: Creating...
yandex_compute_instance.fe_instance["vm-2"]: Still creating... [10s elapsed]
yandex_compute_instance.fe_instance["vm-1"]: Still creating... [10s elapsed]
yandex_compute_instance.fe_instance["vm-2"]: Still creating... [20s elapsed]
yandex_compute_instance.fe_instance["vm-1"]: Still creating... [20s elapsed]
yandex_compute_instance.fe_instance["vm-2"]: Still creating... [30s elapsed]
yandex_compute_instance.fe_instance["vm-1"]: Still creating... [30s elapsed]
yandex_compute_instance.fe_instance["vm-1"]: Still creating... [40s elapsed]
yandex_compute_instance.fe_instance["vm-2"]: Still creating... [40s elapsed]
yandex_compute_instance.fe_instance["vm-1"]: Creation complete after 40s [id=fhms7jmrfj1q4upi2p3v]
yandex_compute_instance.fe_instance["vm-2"]: Creation complete after 42s [id=fhmn497koe2vmctt3mkj]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

![screenshot](/screenshots/vms.png)

### Задание 3

[disk_vm.tf](/src/disk_vm.tf)

![screenshot](/screenshots/disk_vm.png)
### Задание 4

[ansible.tf](/src/ansible.tf)
[inventory.tftpl](/src/ansible.tftpl)

Вывод ansible:
```
null_resource.web_hosts_provision (local-exec): PLAY RECAP *********************************************************************
null_resource.web_hosts_provision (local-exec): develop-web-1              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): develop-web-2              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): storage                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): vm-1                       : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): vm-2                       : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Файл inventory:
```
[webservers]

develop-web-1   ansible_host=158.160.114.168

develop-web-2   ansible_host=158.160.125.227

[databases]

vm-1   ansible_host=158.160.45.232

vm-2   ansible_host=158.160.120.195

[storage]
  
storage   ansible_host=158.160.117.93
```
