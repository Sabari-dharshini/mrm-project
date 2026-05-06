output "ec2_public_ip" {
  description = "EC2 public IP address (use this everywhere as EC2_PUBLIC_IP)"
  value       = aws_eip.mrm_eip.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (host only, no port)"
  value       = aws_db_instance.mrm_postgres.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.mrm_postgres.port
}

output "database_url" {
  description = "Full DATABASE_URL for your .env file"
  value       = "postgresql://postgres:PASSWORD@${aws_db_instance.mrm_postgres.address}:5432/mrmpg"
  sensitive   = false
}

output "app_urls" {
  description = "Application URLs after deployment"
  value = {
    user_ui   = "http://${aws_eip.mrm_eip.public_ip}:5173"
    admin_ui  = "http://${aws_eip.mrm_eip.public_ip}:5174"
    member_ui = "http://${aws_eip.mrm_eip.public_ip}:5175"
    api       = "http://${aws_eip.mrm_eip.public_ip}:5000"
  }
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.mrm_eip.public_ip}"
}
