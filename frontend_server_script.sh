#!/bin/bash
set -e  # exit immediately if a command fails

# ==============================
# CONFIGURABLE VARIABLES
# ==============================
BACKEND_HOST="192.168.1.200"   # <-- Replace with your Backend server IP
FRONTEND_ZIP="https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip"
NGINX_HTML_DIR="/usr/share/nginx/html"

# ==============================
# INSTALL NGINX
# ==============================
echo "📦 Installing Nginx..."
dnf install nginx -y

echo "🚀 Enabling and starting Nginx..."
systemctl enable nginx
systemctl start nginx

# ==============================
# DEPLOY FRONTEND CONTENT
# ==============================
echo "🧹 Removing default Nginx content..."
rm -rf $NGINX_HTML_DIR/*

echo "⬇️ Downloading frontend code..."
curl -o /tmp/frontend.zip $FRONTEND_ZIP

echo "📂 Extracting frontend content..."
cd $NGINX_HTML_DIR
unzip /tmp/frontend.zip

# ==============================
# CONFIGURE NGINX REVERSE PROXY
# ==============================
echo "⚙️ Creating Nginx reverse proxy config..."
cat <<EOF > /etc/nginx/default.d/expense.conf
proxy_http_version 1.1;

location /api/ {
  proxy_pass http://$BACKEND_HOST:8080/;
}

location /health {
  stub_status on;
  access_log off;
}
EOF

# ==============================
# RESTART NGINX
# ==============================
echo "🔄 Restarting Nginx..."
systemctl restart nginx

# ==============================
# VERIFICATION
# ==============================
echo "----------------------------------"
echo "🔍 Checking Nginx service status..."
systemctl status nginx --no-pager

echo "----------------------------------"
echo "🌐 Checking listening ports (Nginx should be on 80)..."
netstat -nptl | grep ":80" || echo "⚠️ Nginx not listening on port 80!"

echo "----------------------------------"
echo "👀 Checking running Nginx processes..."
ps -ef | grep [n]ginx || echo "⚠️ No Nginx process found!"

echo "----------------------------------"
echo "✅ Frontend setup completed! Try accessing http://<your-server-ip> in a browser."
