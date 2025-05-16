terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
  default     = ""
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = "WPConcierge AWS Key"
}

resource "digitalocean_droplet" "wpc" {
  name     = "wpc"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  image    = "ubuntu-24-04-x64"
  ssh_keys = [digitalocean_ssh_key.default.id]
  tags     = ["wpconcierge"]
}

resource "digitalocean_domain" "wpconcierge_org" {
  name = "wpconcierge.org"
}

resource "digitalocean_record" "wpc" {
  domain = digitalocean_domain.wpconcierge_org.name
  type   = "A"
  name   = "wpc"
  value  = digitalocean_droplet.wpc.ipv4_address
  ttl    = 300
}