#!/bin/bash

# Script: patch_hostvn.sh
# Mota: Tu dong sua loi 520 va cau hinh Nginx FastCGI Cache cho HostVN VPS (Ho tro moi domain)
# Tac gia: Antigravity
# Ngay: $(date +%Y-%m-%d)

# Kiem tra quyen root
if [ "$EUID" -ne 0 ]; then
  echo "Vui long chay script voi quyen root!"
  echo "Su dung: sudo bash patch_hostvn.sh [domain.com]"
  exit 1
fi

# Nhan tham so domain
DOMAIN=$1

# Neu khong truyen tham so, yeu cau nhap
if [ -z "$DOMAIN" ]; then
    echo "Ban chua nhap ten mien."
    read -p "Vui long nhap ten mien (vidu: azevent.vn): " DOMAIN
fi

# Chuan hoa ten mien (xoa khoang trang du thua)
DOMAIN=$(echo "$DOMAIN" | xargs)

if [ -z "$DOMAIN" ]; then
    echo "Loi: Ten mien khong duoc de trong!"
    exit 1
fi

# Tao ten bien cho cache (thay the dau cham bang dau gach duoi)
CACHE_KEY=$(echo "$DOMAIN" | tr '.' '_')
CACHE_PATH="/var/cache/nginx/$CACHE_KEY"
SITE_CONF="/etc/nginx/sites-enabled/$DOMAIN.conf"

echo ">> Bat dau tien trinh sua loi va cau hinh cache cho: $DOMAIN"
echo ">> Cache Key: $CACHE_KEY"
echo ">> Config File: $SITE_CONF"
echo "--------------------------------------------------------"

# 1. Sua loi 520 (Map config chan nham file .html)
# Day la cau hinh toan cuc, chi can chay 1 lan la ap dung cho tat ca domain
MAP_CONF="/etc/nginx/conf.d/map.conf"
if [ -f "$MAP_CONF" ]; then
    echo "[1/3] Dang kiem tra $MAP_CONF (Global config)..."
    
    if grep -q "\~*\^/\.+\\\.ht\[\^/\]*\$" "$MAP_CONF"; then
        echo "=> Phat hien regex loi 520. Dang sua..."
        cp "$MAP_CONF" "${MAP_CONF}.bak_$(date +%s)"
        sed -i 's|\~*\^/\.+\\\.ht\[\^/\]*\$|\~*/\\.ht\[\^/\]*|g' "$MAP_CONF"
        echo "=> Da cap nhat regex map.conf."
    else
        echo "=> Regex trong map.conf da dung (hoac da duoc sua truoc do)."
    fi
else
    echo "=> KHONG TIM THAY file $MAP_CONF. Bo qua buoc nay."
fi


# 2. Cau hinh Nginx FastCGI Cache cho domain cu the
if [ -f "$SITE_CONF" ]; then
    echo "[2/3] Dang cau hinh FastCGI Cache cho $SITE_CONF..."

    # Kiem tra xem da cau hinh chua
    # Check neu file config da chua duong dan cache cua domain nay
    if grep -q "fastcgi_cache_path.*/var/cache/nginx/$CACHE_KEY" "$SITE_CONF"; then
        echo "=> Website nay da duoc cau hinh cache roi. Bo qua."
    else
        # Sao luu file config
        cp "$SITE_CONF" "${SITE_CONF}.bak_$(date +%s)"
        
        # 2.1 Tao thu muc cache
        if [ ! -d "$CACHE_PATH" ]; then
            echo "=> Dang tao thu muc cache: $CACHE_PATH"
            mkdir -p "$CACHE_PATH"
            chown -R www-data:www-data /var/cache/nginx
        fi

        # 2.2 Them fastcgi_cache_path vao #INIT_FASTCGI_CACHE
        if grep -q "#INIT_FASTCGI_CACHE" "$SITE_CONF"; then
            sed -i "s|#INIT_FASTCGI_CACHE|fastcgi_cache_path ${CACHE_PATH} levels=1:2 keys_zone=${CACHE_KEY}:100m inactive=60m;|" "$SITE_CONF"
            echo "=> Da them directive fastcgi_cache_path."
        else
            echo "=> KHONG TIM THAY placeholder '#INIT_FASTCGI_CACHE'. Khong the tu dong them fastcgi_cache_path."
        fi

        # 2.3 Them directives cache vao block PHP (#BEGIN_FASTCGI_CACHE)
        if grep -q "#BEGIN_FASTCGI_CACHE" "$SITE_CONF"; then
            sed -i "/#BEGIN_FASTCGI_CACHE/a \\
        fastcgi_cache ${CACHE_KEY};\\
        fastcgi_cache_valid 200 60m;\\
        fastcgi_cache_use_stale error timeout invalid_header http_500;\\
        add_header X-FastCGI-Cache \$upstream_cache_status;" "$SITE_CONF"
            
            echo "=> Da them cac directive FastCGI Cache vao block PHP."
        else
             echo "=> KHONG TIM THAY placeholder '#BEGIN_FASTCGI_CACHE'. Khong the tu dong them directives cache."
        fi
    fi
else
    echo "=> LOI: KHONG TIM THAY file cau hinh cho domain $DOMAIN."
    echo "=> Duong dan du kien: $SITE_CONF"
    echo "=> Vui long kiem tra xem ban da them website nay tren HostVN script chua."
fi


# 3. Kiem tra va Reload Nginx
echo "[3/3] Kiem tra va Reload Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "=> Cau hinh Hop le. Dang reload Nginx..."
    systemctl reload nginx
    echo ""
    echo "========================================================"
    echo "   HOAN TAT! Website $DOMAIN da duoc xu ly."
    echo "========================================================"
else
    echo ""
    echo ">>> LOI: Cau hinh Nginx bi loi cu phap."
    echo ">>> Vui long kiem tra output ben tren va restore file backup *.bak neu can."
    exit 1
fi
