resource "yandex_compute_instance" "fe_instance" {
  depends_on = [yandex_compute_instance.web]
  for_each = { for vm in local.vms_fe: "${vm.vm_name}" => vm }
  name = each.key
  platform_id = "standard-v1"
  resources {
    cores       = each.value.cpu
    memory      = each.value.ram
    core_fraction = each.value.frac
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat     = true
  }
  metadata = {
    ssh-keys = local.ssh
  }
}

locals {
  vms_fe = [
    {
      vm_name = "vm-1"
      cpu   = 2
      ram   = 1
      frac  = 5
    },
    {
      vm_name = "vm-2"
      cpu   = 2
      ram   = 1
      frac  = 5
    }
  ]
  ssh = "ubuntu:${file(var.ssh_key_path)}"
}
