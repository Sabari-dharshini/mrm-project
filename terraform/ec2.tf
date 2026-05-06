# ── Key Pair ─────────────────────────────────────────────────
# You provide your public key via variable
resource "aws_key_pair" "mrm_key" {
  key_name   = "mrm-keypair"
  public_key = var.ec2_public_key
}

# ── EC2 Instance ─────────────────────────────────────────────
# Free tier: t2.micro (1 vCPU, 1GB RAM) or t3.micro
resource "aws_instance" "mrm_ec2" {
  ami                    = var.ec2_ami
  instance_type          = "t2.micro"          # Free tier eligible
  key_name               = aws_key_pair.mrm_key.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Storage - free tier gives 30GB EBS
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }

  # Bootstrap script - runs once on first boot
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    github_repo  = var.github_repo_url
    db_url       = var.database_url
    jwt_secret   = var.jwt_secret
    email_user   = var.email_user
    email_pass   = var.email_pass
    email_from   = var.email_from
    company_name = var.company_name
  }))

  tags = {
    Name    = "mrm-pg-server"
    Project = "mrm-pg"
  }
}

# ── Elastic IP (static public IP) ───────────────────────────
resource "aws_eip" "mrm_eip" {
  instance = aws_instance.mrm_ec2.id
  domain   = "vpc"

  tags = {
    Name    = "mrm-eip"
    Project = "mrm-pg"
  }
}
