terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
  default     = "" # Set via environment variable DO_TOKEN
  sensitive   = true
}

variable "do_public_key" {
  type        = string
  description = "SSH public key for droplet"
  default     = "" # Set via environment variable DO_PUBLIC_KEY
  sensitive   = true
}

resource "digitalocean_ssh_key" "default" {
  name       = "wpc-ssh-key"
  public_key = var.do_public_key
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