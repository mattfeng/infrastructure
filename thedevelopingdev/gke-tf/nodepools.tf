resource "google_container_node_pool" "worker" {
  name       = var.nodepools.worker
  location   = var.zone
  cluster    = google_container_cluster.devcluster.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "n2d-standard-2"
    disk_size_gb = 50

    labels = {
      node_pool = var.nodepools.worker
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/monitoring"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_container_node_pool" "ingress" {
  name       = var.nodepools.ingress
  location   = var.zone
  cluster    = google_container_cluster.devcluster.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    preemptible   = true
    machine_type  = "e2-micro"
    disk_size_gb  = 10

    taint = [
      {
        key    = "ingress"
        value  = "true"
        effect = "NO_EXECUTE"
      }
    ]

    labels = {
      node_pool = var.nodepools.ingress
    }

    tags = [
      "ingress"
    ]

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_container_node_pool" "compute" {
  name       = var.nodepools.compute
  location   = var.zone
  cluster    = google_container_cluster.devcluster.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    preemptible   = true
    machine_type  = "n1-standard-8"
    disk_size_gb  = 20

    guest_accelerator {
      type = "nvidia-tesla-k80"      # 16 GB memory
      count = 1
    }

    labels = {
      node_pool = var.nodepools.compute
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
