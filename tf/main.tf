terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg_1" {
  name = "default"

  ingress {
    description = "App Port"
    from_port   = 8000
    to_port     = 8000
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


resource "aws_key_pair" "google_key" {
  key_name   = "google-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDf413PFOlco2zNQiq3XxIwXI5x2YHp3/+oB5PFCj5EZiek6e0gYnwocSVVYyT9tJAqS9l1NgyzYABrbN5tclvc0ABNemCZtMNSyPkxlRCXnhgMUWR+LAna6VqO168oGPFQENAykEfnSJhcneKPSTJrlQvcFOVku37fNNejzJL2Py47UGgwoGyJoE8CXxL4ts/HK+a5SOzllhy7a0NCipBZdnbWzwmaEmLd6H0sNCnY33eB+qUZdn5dPuJrH/gbgmT+R+mISNwy85BkDnTIn8HW9UY5ydtVq/N+kQPa9WhA78rdonyagd9VNTnO60o/e2J4iE59rk5G4Hj0OXw46uFb sinor@DESKTOP-5H8LO34"
}

resource "aws_instance" "server_1" {
  ami                         = "ami-ff0fea8310f3"
  instance_type               = "t3.micro"
  count                       = 2
  key_name                    = aws_key_pair.google_key.key_name
  security_groups             = [aws_security_group.sg_1.name]
  user_data                   = <<-EOF
              #!/bin/bash
              apt update -y
              apt install git -y
              apt install curl -y

              # Install NVM
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              . ~/.nvm/nvm.sh

              # Install Node.js 18
              nvm install 18

              # Install PM2
              npm install pm2 -g

              # Clone Node.js repository
              git clone https://github.com/KimangKhenng/devops-ex /root/devops-ex

              # Navigate to the repository and start the app with PM2
              cd /root/devops-ex
              npm install
              pm2 start app.js --name node-app -- -p 8000
            EOF
  user_data_replace_on_change = true
}