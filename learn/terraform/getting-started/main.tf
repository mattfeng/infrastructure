terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  version     = "3.5.0"
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region 
  zone    = var.zone
}

# VPC
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# GCE 
## Static IP address
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

## Compute instance
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  # typically, provisioning should be done via Packer
  #   which would create immutable infrastructure
  provisioner "local-exec" {
    command = "echo ${google_compute_instance.vm_instance.name}: ${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} >> ip_address.txt"
  }
}