variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0f58b397bc5c1f2e8"
}

variable "key_name" {
  default = "ecommerce-key-tf"
}

variable "public_key_path" {
  default = "~/.ssh/ecommerce-key.pub"
}

variable "project_name" {
  default = "ecommerce-devops"
}