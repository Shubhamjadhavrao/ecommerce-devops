# variables.tf
# All configurable values here

variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  type        = string
  # Ubuntu 22.04 in ap-south-1 (Mumbai)
  default     = "ami-0f58b397bc5c1f2e8"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
  default     = "ecommerce-key"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecommerce-devops"
}