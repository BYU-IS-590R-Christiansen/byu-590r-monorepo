output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.byu_590r_server.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.byu_590r_server.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.byu_590r_eip.public_ip
}

output "ec2_host" {
  description = "EC2 host (Elastic IP - more stable than dynamic IP)"
  value       = aws_eip.byu_590r_eip.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.byu_590r_sg.id
}

output "s3_bucket_dev" {
  description = "S3 bucket name for development"
  value       = aws_s3_bucket.dev.id
}

output "s3_bucket_prod" {
  description = "S3 bucket name for production"
  value       = aws_s3_bucket.prod.id
}

output "s3_bucket" {
  description = "S3 bucket name (defaults to production for backward compatibility)"
  value       = aws_s3_bucket.prod.id
}

output "allocation_id" {
  description = "Elastic IP allocation ID"
  value       = aws_eip.byu_590r_eip.id
}

output "github_secrets_instructions" {
  description = "Instructions for setting up GitHub secrets"
  value = <<-EOT
    Update GitHub Actions secrets:
    
    1. EC2_HOST = ${aws_eip.byu_590r_eip.public_ip}
    2. S3_BUCKET (PROD) = ${aws_s3_bucket.prod.id}
    3. S3_BUCKET_DEV = ${aws_s3_bucket.dev.id}
    4. EC2_SSH_PRIVATE_KEY = (Copy contents of ~/.ssh/${var.key_name}.pem)
    
    For local development, add to backend/.env:
    S3_BUCKET = ${aws_s3_bucket.dev.id}
    
    Application URLs:
    Frontend: http://${aws_eip.byu_590r_eip.public_ip}
    Backend API: http://${aws_eip.byu_590r_eip.public_ip}:4444/api/hello
  EOT
}

