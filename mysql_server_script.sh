#!/bin/bash
set -e  # exit immediately if a command fails

echo "📦 Installing MySQL Server..."
dnf install mysql-server -y

echo "🚀 Enabling and starting MySQL service..."
systemctl enable mysqld
systemctl start mysqld

echo "🔑 Setting root password..."
mysql_secure_installation --set-root-pass ExpenseApp@1

echo "✅ MySQL installation and setup completed!"

echo "----------------------------------"
echo "🔍 Checking MySQL service status..."
systemctl status mysqld --no-pager

echo "----------------------------------"
echo "🌐 Checking listening ports (MySQL should be on 3306)..."
netstat -nptl | grep 3306 || echo "⚠️ MySQL port 3306 not found!"

echo "----------------------------------"
echo "👀 Checking running MySQL processes..."
ps -ef | grep [m]ysql || echo "⚠️ No MySQL process found!"
