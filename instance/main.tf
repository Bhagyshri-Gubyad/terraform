# terraform {
#   required_version = "1"
# }
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
resource "aws_key_pair" "my_key" {
  key_name   = "tfmkey"
  public_key = file("${path.module}/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sshaccess" {
  name = "ssh-access"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"  ]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "http"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "tfminst" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.sshaccess.id ]

  # lifecycle {
  #   prevent_destroy = true
  # }
  user_data     = file("${path.module}/script.sh")
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("${path.module}/.ssh/id_rsa")
  }
  provisioner "local-exec" {
    command = "echo testing > ./testing.txt"

  }
  provisioner "remote-exec" {
    inline = [

      "pwd > ./test.txt",
      "mkdir tfmdir"
    ]
  }
}
output "pubIp" {
  value = aws_instance.tfminst.public_ip
}

# data “aws_ami” “amilist” {
# Oweners = 
# Most_recent= true
# Filters { as per required condition 
#  Ami= [“myami *“]
# }}
