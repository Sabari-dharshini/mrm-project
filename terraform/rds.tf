# ── RDS Subnet Group ─────────────────────────────────────────
resource "aws_db_subnet_group" "mrm_db_subnet" {
  name       = "mrm-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name    = "mrm-db-subnet-group"
    Project = "mrm-pg"
  }
}

# ── RDS PostgreSQL Instance ──────────────────────────────────
# Free tier: db.t3.micro, 20GB gp2 storage, single-AZ
resource "aws_db_instance" "mrm_postgres" {
  identifier        = "mrm-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"       # Free tier eligible

  # Storage - free tier gives 20GB
  allocated_storage     = 20
  max_allocated_storage = 20              # No auto-scaling (free tier)
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database credentials
  db_name  = "mrmpg"
  username = "postgres"
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.mrm_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false          # Private only - accessed via EC2

  # Free tier settings
  multi_az               = false          # Single AZ (not free in multi-AZ)
  deletion_protection    = false          # Set true in real production
  skip_final_snapshot    = true           # Set false in real production
  backup_retention_period = 0            # Disable automated backups (free tier)

  tags = {
    Name    = "mrm-postgres"
    Project = "mrm-pg"
  }
}
