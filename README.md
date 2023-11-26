## Задание 1

Прописал правила группы безопасности Yandex cloud по протоколу TCP для портов 22(SSH), 80(HTTP), 443(HTTPS) для любых источников входящих подключений:

![screenshot](/screenshots/securty_group.png)

## Задание 2

1. Создал файл count-vm.tf. Описал в нём создание двух одинаковых ВМ web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент count loop. Назначил ВМ созданную в первом задании группу безопасности [count-vm.tf](/src/count-vm.tf):
```
resource "yandex_compute_instance" "web" {
  count = 2
  name = "develop-web-${count.index + 1}"
  resources {
	cores     	= 2
	memory    	= 1
	core_fraction = 5
  }

  boot_disk {
	initialize_params {
  	image_id = "fd8g64rcu9fq5kpfqls0"
	}
  }

  network_interface {
	subnet_id = yandex_vpc_subnet.develop.id
	nat   	= true
  }

  metadata = {
	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

2. Создал файл for_each-vm.tf. В нём описано создание двух ВМ для баз данных с именами "main" и "replica" разных по cpu/ram/disk , используется мета-аргумент **for_each loop**. Использована для обеих ВМ одна общая переменная типа list(object({ vm_name=string, cpu=number, ram=number, disk=number })) [for_each-vm.tf](/src/for_each-vm.tf):
```
resource "yandex_compute_instance" "fe_instance" {

depends_on = [ yandex_compute_instance.web ]

  for_each = { for vm in local.vms_fe: "${vm.vm_name}" => vm }
  name = each.key
  platform_id = "standard-v1"
  resources {
 	cores     	= each.value.cpu
 	memory    	= each.value.ram
 	core_fraction = each.value.frac
  }

  boot_disk {
	initialize_params {
  	image_id = "fd8g64rcu9fq5kpfqls0"
	}
  }

  network_interface {
	subnet_id = yandex_vpc_subnet.develop.id
	nat   	= true
  }

  metadata = {
#	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
	ssh-keys = local.ssh
  }
}

locals {
  vms_fe = [
	{
   	vm_name = "vm-1"
   	cpu 	= 2
   	ram 	= 1
   	frac	= 5
	},
	{
   	vm_name = "vm-2"
   	cpu 	= 2
   	ram 	= 1
   	frac	= 5
	}
  ]
}

locals {
  ssh = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}
```

3. Использую переменную depends_on для того, чтобы соблюсти условие первичного запуска виртуальных машин из первого пункта:
```
depends_on = [ yandex_compute_instance.web ]
```

4. Использую функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata:
```
 metadata = {
	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
```

![screenshot](/screenshots/vms.png)

### Задание 3

1. Создал 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле disk_vm.tf.
2. Создал в том же файле одиночную ВМ c именем "storage" . Использовал блок dynamic secondary_disk{..} и мета-аргумент for_each для подключения созданных мной дополнительных дисков.
[disk_vm.tf](/src/disk_vm.tf):
```
resource "yandex_compute_disk" "stor" {
  count   = 3
  name	= "disk-${count.index + 1}"
  size	= 1
}


resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
	cores     	= 2
	memory    	= 1
	core_fraction = 5
  }

  boot_disk {
	initialize_params {
  	image_id = "fd8g64rcu9fq5kpfqls0"
	}
  }

# Ошибка в том, что ${secondary_disk.key} и ${yandex_compute_disk.stor.*.id} позволяли добавлять любые значения включая цифры, 
# исправленный вариант выглядит так:

  dynamic "secondary_disk" {
  for_each = yandex_compute_disk.stor.*.id
  content {
    disk_id = yandex_compute_disk.stor[secondary_disk.key].id
  }
}

  network_interface {
	subnet_id = yandex_vpc_subnet.develop.id
	nat   	= true
  }

  metadata = {
	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

![screenshot](/screenshots/disk_vm.png)
### Задание 4
1. В файле ansible.tf создал inventory-файл для ansible. Использовал функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции. Готовый код взял из демонстрации к лекции. Передал в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2.
2. Инвентарь содержит 3 группы [webservers], [databases], [storage] и является динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ [ansible.tf](/src/ansible.tf):
```
resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl", {
    webservers     = yandex_compute_instance.web,
    fe_instance    = yandex_compute_instance.fe_instance,
    stor_instance  = [yandex_compute_instance.storage]
  })
  filename = "${abspath(path.module)}/inventory"
}

resource "null_resource" "web_hosts_provision" {
  depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]


  # ansible-playbook
  provisioner "local-exec" {
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/inventory ${abspath(path.module)}/test.yml"
    on_failure = continue # Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }

  triggers = {
    always_run        = "${timestamp()}"
    playbook_src_hash = file("${abspath(path.module)}/test.yml")
  }
}
```
Получившийся файл [inventory.tftpl](/src/ansible.tftpl):
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

Вывод ansible:
```
null_resource.web_hosts_provision (local-exec): PLAY RECAP *********************************************************************
null_resource.web_hosts_provision (local-exec): develop-web-1              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): develop-web-2              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): storage                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): vm-1                       : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): vm-2                       : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
### Дополнение к ДЗ:
```
# Ошибка в том, что ${secondary_disk.key} и ${yandex_compute_disk.stor.*.id} позволяли добавлять любые значения включая цифры, 
# исправленный вариант выглядит так:

  dynamic "secondary_disk" {
  for_each = yandex_compute_disk.stor.*.id
  content {
    disk_id = yandex_compute_disk.stor[secondary_disk.key].id
  }
}
```
