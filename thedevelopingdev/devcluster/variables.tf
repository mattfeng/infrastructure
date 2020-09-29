variable "cluster_name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "credentials_file" {
  type = string
}

variable "nodepools" {
  type = map
  default = {
    "worker"  = "worker-pool"
    "ingress" = "ingress-pool"
    "compute" = "compute-pool"
  }
}