resource "yandex_compute_disk" "stor" {
  count   = var.disk_count
  name    = "${var.instance_name_disk}-${count.index + 1}-${var.disk_name_prefix}"
  size    = var.disk_size_gb
}

resource "yandex_compute_instance" "storage" {
  name = var.instance_name
  resources {
    cores        = var.instance_cores
    memory       = var.instance_memory
    core_fraction = var.instance_core_fraction
  }

  boot_disk {
	initialize_params {
  	image_id = var.image_id
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
	subnet_id = var.subnet_id
	nat   	= true
  }

  metadata = {
	ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}
