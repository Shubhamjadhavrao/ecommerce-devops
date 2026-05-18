# outputs.tf
# Values shown after terraform apply

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.ecommerce_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.ecommerce_server.public_dns
}

output "s3_bucket_name" {
  description = "S3 backup bucket name"
  value       = aws_s3_bucket.ecommerce_backup.bucket
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.ecommerce_vpc.id
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}"
}