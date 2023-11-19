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
