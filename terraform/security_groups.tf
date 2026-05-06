# ── EC2 Security Group ───────────────────────────────────────
resource "aws_security_group" "ec2_sg" {
  name        = "mrm-ec2-sg"
  description = "Security group for MRM PG EC2 instance"
  vpc_id      = aws_vpc.mrm_vpc.id

  # SSH - restrict to your IP in production
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your IP: ["YOUR.IP.ADDRESS/32"]
  }

  # User UI
  ingress {
    description = "User UI"
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Admin UI
  ingress {
    description = "Admin UI"
    from_port   = 5174
    to_port     = 5174
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Member UI
  ingress {
    description = "Member UI"
    from_port   = 5175
    to_port     = 5175
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API
  ingress {
    description = "Backend API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "mrm-ec2-sg"
    Project = "mrm-pg"
  }
}

# ── RDS Security Group ───────────────────────────────────────
resource "aws_security_group" "rds_sg" {
  name        = "mrm-rds-sg"
  description = "Security group for MRM PG RDS instance"
  vpc_id      = aws_vpc.mrm_vpc.id

  # PostgreSQL - only from EC2 security group
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "mrm-rds-sg"
    Project = "mrm-pg"
  }
}
