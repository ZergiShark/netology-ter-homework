resource "yandex_compute_instance" "web" {
  count = 2
  name = "develop-web-${count.index + 1}"
  resources {
    cores       = 2
    memory      = 1
    core_fraction = 5
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
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}
