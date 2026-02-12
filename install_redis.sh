#!/bin/bash

# Script: install_redis.sh
# Mota: Tu dong cai dat Redis Server va PHP-Redis extension cho HostVN VPS
# Tac gia: Antigravity
# Ngay: $(date +%Y-%m-%d)

# Kiem tra quyen root
if [ "$EUID" -ne 0 ]; then
  echo "Vui long chay script voi quyen root!"
  echo "Su dung: sudo bash install_redis.sh"
  exit 1
fi

echo "========================================================"
echo "   HOSTVN REDIS INSTALLER"
echo "========================================================"

# 1. Cap nhat danh sach goi
echo "[1/4] Cap nhat he thong..."
apt-get update -y

# 2. Cai dat Redis Server
echo "[2/4] Dang cai dat Redis Server..."
apt-get install redis-server -y

# Cau hinh Redis co ban (doi giam sat systemd)
sed -i 's/^supervised no/supervised systemd/' /etc/redis/redis.conf

# Restart Redis
systemctl restart redis.service
systemctl enable redis.service

# 3. Cai dat PHP Redis Extension
echo "[3/4] Dang cai dat PHP Redis Extension..."
# Cai dat php-redis (tu dong chon phien ban PHP mac dinh cua he thong)
apt-get install php-redis -y

# 4. Restart services
echo "[4/4] Restart PHP-FPM va Nginx..."

# Restart tat ca cac service php-fpm dang chay
systemctl list-units --type=service | grep php | grep fpm | awk '{print $1}' | xargs systemctl restart

# Reload Nginx
systemctl reload nginx

# 5. Cai dat Redis Manager Menu
echo "[5/5] Cai dat menu quan ly Redis..."
curl -sL https://raw.githubusercontent.com/leluongnghia/hostvn-patch-script/main/redis_manager.sh -o /usr/local/bin/redis-manager
chmod +x /usr/local/bin/redis-manager

echo "========================================================"
echo "   HOAN TAT! Redis da duoc cai dat."
echo "   - Redis Status: $(systemctl is-active redis-server)"
echo "   - PHP Redis: Da cai dat."
echo ""
echo "   👉 Go lenh sau de quan ly Redis (Start/Stop/Restart):"
echo "      redis-manager"
echo "========================================================"
