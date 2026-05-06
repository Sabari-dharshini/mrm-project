#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  MRM PG - EC2 Bootstrap Script
#  Runs automatically on first boot via Terraform user_data.
#  Installs Docker, clones GitHub repo, writes .env, starts app.
# ─────────────────────────────────────────────────────────────

set -e
LOG="/var/log/mrm-bootstrap.log"
exec > >(tee -a $LOG) 2>&1

echo "=============================="
echo " MRM PG Bootstrap Starting"
echo " $(date)"
echo "=============================="

# ── 1. System update ─────────────────────────────────────────
apt-get update -y
apt-get upgrade -y
apt-get install -y curl git unzip ca-certificates gnupg lsb-release

# ── 2. Install Docker ────────────────────────────────────────
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

echo "Docker installed: $(docker --version)"
echo "Docker Compose installed: $(docker compose version)"

# ── 3. Clone GitHub repo ─────────────────────────────────────
APP_DIR="/home/ubuntu/mrm-project"

if [ -d "$APP_DIR" ]; then
  echo "Repo already exists, pulling latest..."
  cd $APP_DIR && git pull
else
  echo "Cloning repo from ${github_repo}..."
  git clone ${github_repo} $APP_DIR
fi

cd $APP_DIR

# ── 4. Get EC2 public IP ─────────────────────────────────────
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "EC2 Public IP: $EC2_IP"

# ── 5. Write .env file ───────────────────────────────────────
cat > $APP_DIR/.env << EOF
EC2_PUBLIC_IP=$EC2_IP

DATABASE_URL=${db_url}

JWT_SECRET=${jwt_secret}
JWT_EXPIRES_IN=450d
BCRYPT_SALT_ROUNDS=12

EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=465
EMAIL_SECURE=true
EMAIL_USER=${email_user}
EMAIL_PASS=${email_pass}
EMAIL_FROM=${email_from}

COMPANY_NAME=${company_name}
COMPANY_WEBSITE=http://$EC2_IP:5173
EOF

echo ".env file written."

# ── 6. Create uploads gitkeep ────────────────────────────────
mkdir -p $APP_DIR/mrmpg-backend/uploads/bills
touch $APP_DIR/mrmpg-backend/uploads/.gitkeep

# ── 7. Build and start all containers ────────────────────────
echo "Starting Docker Compose build (this takes 5-10 minutes)..."
cd $APP_DIR
docker compose --env-file .env up -d --build

echo "=============================="
echo " Bootstrap Complete!"
echo " $(date)"
echo ""
echo " App URLs:"
echo "   User UI   : http://$EC2_IP:5173"
echo "   Admin UI  : http://$EC2_IP:5174"
echo "   Member UI : http://$EC2_IP:5175"
echo "   API       : http://$EC2_IP:5000"
echo ""
echo " Admin Login:"
echo "   Email   : admin@gmail.com"
echo "   Password: Admin@123"
echo "=============================="
