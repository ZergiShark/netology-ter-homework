resource "yandex_compute_instance" "web" {
  count = var.instance_count
  name = "${var.name_prefix}-${count.index + 1}"
  resources {
    cores       = var.instance_cores
    memory      = var.instance_memory
    core_fraction = var.instance_core_fraction
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
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}
