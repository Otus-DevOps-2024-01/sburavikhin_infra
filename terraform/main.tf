terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
 #   token = "y0_AgAAAAB0L2AOAATuwQAAAAD97OE1AAC1LvXxUx9MaLd34G06cXnk59bnRA"
 #   cloud_id = "b1g2jd4tvdu5gt0ld2oa"
 #   folder_id = "b1gch9mp5o87jlud842j"
 #   zone = "ru-central1-a"

  token = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
    }   

resource "yandex_compute_instance" "app" {
  name = "reddit-app"

  resources {
    cores  = 2
    memory = 2
  }

connection {
  type = "ssh"
  host = yandex_compute_instance.app.network_interface.0.nat_ip_address
  user = "ubuntu"
  agent = false
  # путь до приватного ключа
  private_key = file("~/.ssh/id_rsa")
  }

provisioner "file" {
  source = "files/puma.service"
  destination = "/tmp/puma.service"
}

provisioner "remote-exec" {
  script = "files/deploy.sh"
}

  metadata = {
  ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }


  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = "fd8ovsq4l24lpspdpggl"
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = "e9bidm37iq6semtoa4d7"
    nat       = true
  }
}