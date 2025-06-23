# Simplified Terraform setup for two EC2 instances with appropriate security rules

resource "aws_security_group" "master_sg" {
  name        = "master-node-sg"
  description = "Security group for master node: SSH, HTTP, HTTPS, and Jenkins"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_security_group" "worker_sg" {
  name        = "worker-node-sg"
  description = "Security group for worker node: SSH only"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.master_sg.name]
  key_name               = var.key_name

  tags = {
    Name = "master-node" #this will be my master node 
  }
}

resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.worker_sg.name]
  key_name               = var.key_name

  tags = {
    Name = "worker-node" #this will be my worker node
  }
}
