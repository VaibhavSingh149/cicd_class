variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "ami_id" {
  type = string
  default = "ami-0b09627181c8d5778"
  description = "The AMI id for the instance I created"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  default = "vaibh-key"
}
