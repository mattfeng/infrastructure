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
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_container_cluster" "dev_cluster" {
  name = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.primary_node_pool
  location   = var.zone
  cluster    = google_container_cluster.dev_cluster.name
  node_count = 3

  node_config {
    preemptible   = true
    machine_type  = "e2-micro"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

# Nodes for loading data
resource "google_container_node_pool" "prepare_nodes" {
  name       = "prepare-nodes"
  location   = var.zone
  cluster    = google_container_cluster.dev_cluster.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    preemptible   = false
    machine_type  = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]

    # kubernetes labels
    labels = {
      node_class = "prepare"
    }
  }
}

resource "google_container_node_pool" "compute_preemptible_nodes" {
  name       = "compute-nodes"
  location   = var.zone
  cluster    = google_container_cluster.dev_cluster.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    preemptible   = true
    machine_type  = "n1-standard-8"

    guest_accelerator {
      type = "nvidia-tesla-k80"      # 16 GB memory
      count = 1
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]

    # kubernetes labels
    labels = {
      node_class = "compute"
    }
  }
}
