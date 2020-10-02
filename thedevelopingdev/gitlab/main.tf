/* CREDENTIALS */

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  version     = "3.40.0"
  credentials = file("/home/eager/drive/keys/gcp/thedevelopingdev/thedevelopingdev-terraform-sa.json")
  project     = "thedevelopingdev"
  region      = "us-central1"
  zone        = "us-central1-c"
}

provider "google-beta" {
  version     = "3.40.0"
  credentials = file("/home/eager/drive/keys/gcp/thedevelopingdev/thedevelopingdev-terraform-sa.json")
  project     = "thedevelopingdev"
  region      = "us-central1"
  zone        = "us-central1-c"
}

/* RESOURCES */

data "google_compute_image" "gitlab_disk_image" {
  name    = "docker-gitlab"
  project = "thedevelopingdev"
}

resource "google_compute_disk" "backup_disk" {
  name    = "gitlab-backup-disk"
  type    = "pd-standard"
  zone    = "us-central1-c"
  size    = 10
}

resource "google_compute_instance_template" "gitlab_it" {
  name_prefix = "gitlab-it-"
  description = "Used to create Gitlab instances."

  machine_type = "custom-1-6144"

  tags = ["gitlab"]

  // boot disk
  disk {
    source_image = data.google_compute_image.gitlab_disk_image.self_link
    disk_size_gb = 20
    auto_delete  = true
    boot         = true
  }

  // persistent disk
  disk {
    source       = google_compute_disk.backup_disk.name
    auto_delete  = false
    boot         = false
  }

  // networking :: no external IP
  network_interface {
    network = "default"
  }

  // preemptible
  scheduling {
    automatic_restart = false
    preemptible       = true
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  // startup script
  metadata_startup_script = file("startup.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "gitlab_ig" {
  provider           = google-beta
  name               = "gitlab-ig"
  base_instance_name = "gitlab-ig"
  zone               = "us-central1-c"
  target_size        = 1

  depends_on = [
    google_compute_instance_template.gitlab_it
  ]

  version {
    name = "gitlab-prod"
    instance_template  = google_compute_instance_template.gitlab_it.id
  }

  stateful_disk {
    device_name = google_compute_instance_template.gitlab_it.disk[1].device_name
    delete_rule = "NEVER"
  }
}
