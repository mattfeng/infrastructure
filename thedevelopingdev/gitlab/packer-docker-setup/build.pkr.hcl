variable "account_key" {
  type = string
  default = null
}

source "googlecompute" "docker" {
  account_file = var.account_key
  project_id   = "thedevelopingdev"
  source_image = "debian-10-buster-v20200910"
  ssh_username = "packer"
  zone         = "us-central1-c"
  image_name   = "docker-gitlab"
}

build {
  sources = [
    "source.googlecompute.docker"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update && sudo apt-get -y upgrade",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
      "sudo apt-key fingerprint 0EBFCD88",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo docker pull gitlab/gitlab-ce:13.4.1-ce.0",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose"
    ]
  }

  provisioner "file" {
    source = "omnibus.docker-compose.yaml"
    destination = "/tmp/docker-compose.yml"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/docker-compose.yml /root/docker-compose.yml"
    ]
  }
}
