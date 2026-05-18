# main.tf
# This file creates all AWS resources

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create VPC (Virtual Private Cloud)
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "ecommerce-vpc"
    Project = "ecommerce-devops"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ecommerce-public-subnet"
    Project = "ecommerce-devops"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = {
    Name    = "ecommerce-igw"
    Project = "ecommerce-devops"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "ecommerce-public-rt"
    Project = "ecommerce-devops"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create Security Group
resource "aws_security_group" "ecommerce_sg" {
  name        = "ecommerce-sg"
  description = "Security group for ecommerce app"
  vpc_id      = aws_vpc.ecommerce_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask API access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ecommerce-sg"
    Project = "ecommerce-devops"
  }
}

# Create EC2 Instance
resource "aws_instance" "ecommerce_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ecommerce_sg.id]
  key_name = var.key_name
  associate_public_ip_address = true

  # Install Docker on startup
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    cd /home/ubuntu
    git clone https://github.com/Shubhamjadhavrao/ecommerce-devops.git
    cd ecommerce-devops
    docker-compose up -d --build
  EOF

  tags = {
    Name    = "ecommerce-server"
    Project = "ecommerce-devops"
  }
}

# Create S3 Bucket for backups
resource "aws_s3_bucket" "ecommerce_backup" {
  bucket = "${var.project_name}-backup-${random_id.bucket_id.hex}"

  tags = {
    Name    = "ecommerce-backup"
    Project = "ecommerce-devops"
  }
}

# Random ID for unique bucket name
resource "random_id" "bucket_id" {
  byte_length = 4
}