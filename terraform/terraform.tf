terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.30.0"
    }
  }
}


resource "linode_sshkey" "k8s" {
  label = "k8s"
  ssh_key = chomp(file("~/.ssh/k8s-lab.pub"))
}

variable "token" {
  type = string
}

variable "pass" {
  type = string
}

provider "linode" {
    token = var.token
}

resource "linode_instance" "master-1" {
    label = "k8s-master1"
    image = "linode/almalinux9"
    region = "us-southeast"
    type = "g6-standard-4"
    authorized_keys = [linode_sshkey.k8s.ssh_key]
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}

resource "linode_instance" "node-11" {
    label = "k8s-node11"
    image = "linode/almalinux9"
    region = "us-southeast"
    type = "g6-standard-4"
    authorized_keys = [linode_sshkey.k8s.ssh_key]
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}

resource "linode_instance" "node-12" {
    label = "k8s-node12"
    image = "linode/almalinux9"
    region = "us-southeast"
    type = "g6-standard-4"
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}

resource "linode_instance" "master-2" {
    label = "k8s-master2"
    image = "linode/almalinux9"
    region = "us-central"
    type = "g6-standard-4"
    authorized_keys = [linode_sshkey.k8s.ssh_key]
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}

resource "linode_instance" "node-21" {
    label = "k8s-node21"
    image = "linode/almalinux9"
    region = "us-central"
    type = "g6-standard-4"
    authorized_keys = [linode_sshkey.k8s.ssh_key]
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}

resource "linode_instance" "node-22" {
    label = "k8s-node22"
    image = "linode/almalinux9"
    region = "us-central"
    type = "g6-standard-4"
    authorized_keys = [linode_sshkey.k8s.ssh_key]
    root_pass = var.pass
    tags = [ "k8s", "labs" ]
}
