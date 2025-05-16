provider "aws" {
  region = "us-east-2"
}

# To generate the SSH key pair for this instance, run:
#   ssh-keygen -t ed25519 -f example-key
# This will create example-key (private) and example-key.pub (public) in this repo.
# Ensure example-key.pub exists before applying this Terraform.

resource "aws_key_pair" "example_key" {
  key_name   = "example-key"
  public_key = file("${path.module}/example-key.pub")
}

resource "aws_security_group" "graviton_sg" {
  name        = "graviton-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "graviton_instance" {
  ami           = "ami-0e8a34246278c21e4" # Ubuntu 24.04 ARM64 us-east-2
  instance_type = "t4g.micro"
  key_name      = aws_key_pair.example_key.key_name
  vpc_security_group_ids = [aws_security_group.graviton_sg.id]

  tags = {
    Name = "graviton-free-tier"
  }
}