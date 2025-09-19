#!/bin/bash
set -e  # exit immediately if a command fails

# ==============================
# CONFIGURABLE VARIABLES
# ==============================
MYSQL_HOST="192.168.1.100"   # <-- Replace with your MySQL server IP
MYSQL_ROOT_PASS="ExpenseApp@1"
APP_USER="expense"
APP_DIR="/app"
BACKEND_ZIP="https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip"

# ==============================
# INSTALL NODEJS 20
# ==============================
echo "📦 Installing NodeJS 20..."
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y

# ==============================
# CREATE APP USER
# ==============================
echo "👤 Creating application user..."
id $APP_USER &>/dev/null || useradd $APP_USER

# ==============================
# SETUP APP DIRECTORY
# ==============================
echo "📂 Setting up application directory..."
rm -rf $APP_DIR
mkdir -p $APP_DIR

echo "⬇️ Downloading backend code..."
curl -o /tmp/backend.zip $BACKEND_ZIP
cd $APP_DIR
unzip /tmp/backend.zip

# ==============================
# INSTALL DEPENDENCIES
# ==============================
echo "📦 Installing npm dependencies..."
cd $APP_DIR
npm install

# ==============================
# CONFIGURE SYSTEMD SERVICE
# ==============================
echo "⚙️ Creating systemd service..."
cat <<EOF > /etc/systemd/system/backend.service
[Unit]
Description=Backend Service

[Service]
User=$APP_USER
Environment=DB_HOST="$MYSQL_HOST"
ExecStart=/bin/node $APP_DIR/index.js
SyslogIdentifier=backend
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ==============================
# LOAD DATABASE SCHEMA
# ==============================
echo "🗄 Installing MySQL client..."
dnf install mysql -y

echo "📥 Loading schema into MySQL..."
mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASS < $APP_DIR/schema/backend.sql

# ==============================
# START BACKEND SERVICE
# ==============================
echo "🚀 Starting backend service..."
systemctl daemon-reload
systemctl enable backend
systemctl restart backend

echo "✅ Backend setup completed successfully!"

# ==============================
# VERIFICATION
# ==============================
echo "----------------------------------"
echo "🔍 Checking Backend service status..."
systemctl status backend --no-pager

echo "----------------------------------"
echo "🌐 Checking listening ports (Node.js should be on 8080 or defined in code)..."
netstat -nptl | grep node || echo "⚠️ No Node.js process listening!"

echo "----------------------------------"
echo "👀 Checking running Backend processes..."
ps -ef | grep [b]ackend || echo "⚠️ No backend process found!"
