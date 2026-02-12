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

echo "========================================================"
echo "   HOSTVN AUTO PATCHER - FIX 520 & SETUP CACHE"
echo "========================================================"

# --- 1. GLOBAL FIX: Sua loi 520 (Map config chan nham file .html) ---
MAP_CONF="/etc/nginx/conf.d/map.conf"
if [ -f "$MAP_CONF" ]; then
    echo "[GLOBAL] Dang kiem tra $MAP_CONF..."
    
    if grep -q "\~*\^/\.+\\\.ht\[\^/\]*\$" "$MAP_CONF"; then
        echo "=> Phat hien regex loi 520. Dang sua..."
        cp "$MAP_CONF" "${MAP_CONF}.bak_$(date +%s)"
        sed -i 's|\~*\^/\.+\\\.ht\[\^/\]*\$|\~*/\\.ht\[\^/\]*|g' "$MAP_CONF"
        echo "=> DA FIX LOI 520 (Updated regex map.conf)."
    else
        echo "=> Regex trong map.conf da dung."
    fi
else
    echo "=> KHONG TIM THAY file $MAP_CONF. Bo qua Global Fix."
fi
echo "--------------------------------------------------------"

# --- FUNCTION: Patch tung domain ---
patch_domain() {
    local DOMAIN=$1
    local SITE_CONF="/etc/nginx/sites-enabled/$DOMAIN.conf"
    
    # Chuan hoa domain
    DOMAIN=$(echo "$DOMAIN" | xargs)
    if [ -z "$DOMAIN" ]; then return; fi

    echo ">> [Scan] Domain: $DOMAIN"

    if [ ! -f "$SITE_CONF" ]; then
        echo "   -> [SKIP] Khong tim thay file config: $SITE_CONF"
        return
    fi
    
    # Tao ten bien cho cache (thay the dau cham bang dau gach duoi)
    CACHE_KEY=$(echo "$DOMAIN" | tr '.' '_')
    CACHE_PATH="/var/cache/nginx/$CACHE_KEY"

    # Kiem tra xem da cau hinh chua
    if grep -q "fastcgi_cache_path.*/var/cache/nginx/$CACHE_KEY" "$SITE_CONF"; then
        echo "   -> [OK] Website da duoc cau hinh cache. Bo qua."
    else
        echo "   -> [PATCH] Dang cau hinh FastCGI Cache..."
        
        # Sao luu file config
        cp "$SITE_CONF" "${SITE_CONF}.bak_$(date +%s)"
        
        # 1. Tao thu muc cache
        if [ ! -d "$CACHE_PATH" ]; then
            mkdir -p "$CACHE_PATH"
            chown -R www-data:www-data /var/cache/nginx
        fi

        # 2. Them fastcgi_cache_path
        if grep -q "#INIT_FASTCGI_CACHE" "$SITE_CONF"; then
            sed -i "s|#INIT_FASTCGI_CACHE|fastcgi_cache_path ${CACHE_PATH} levels=1:2 keys_zone=${CACHE_KEY}:100m inactive=60m;|" "$SITE_CONF"
        else
            echo "   -> [WARN] Khong tim thay placeholder '#INIT_FASTCGI_CACHE' trong config."
        fi

        # 3. Them directives cache
        if grep -q "#BEGIN_FASTCGI_CACHE" "$SITE_CONF"; then
            BLOCK="fastcgi_cache ${CACHE_KEY};\\
        fastcgi_cache_valid 200 60m;\\
        fastcgi_cache_use_stale error timeout invalid_header http_500;\\
        add_header X-FastCGI-Cache \$upstream_cache_status;"
            sed -i "/#BEGIN_FASTCGI_CACHE/a $BLOCK" "$SITE_CONF"
            echo "   -> [OK] Da update config thanh cong."
        else
             echo "   -> [WARN] Khong tim thay placeholder '#BEGIN_FASTCGI_CACHE' trong config."
        fi
    fi
}

# --- MAIN LOGIC ---
TARGET_DOMAIN=$1

if [ -n "$TARGET_DOMAIN" ]; then
    # TH1: Patch 1 domain cu the
    patch_domain "$TARGET_DOMAIN"
else
    # TH2: Patch ALL
    echo "(!) Khong co ten mien duoc chi dinh."
    echo "(!) Tu dong quet va xu ly tat ca domain trong /etc/nginx/sites-enabled/ ..."
    echo "--------------------------------------------------------"
    
    shopt -s nullglob
    for config_file in /etc/nginx/sites-enabled/*.conf; do
        filename=$(basename "$config_file")
        domain="${filename%.conf}"
        
        # Bo qua file mac dinh
        if [[ "$domain" == "default" ]]; then continue; fi

        patch_domain "$domain"
    done
fi

# --- RELOAD NGINX ---
echo "--------------------------------------------------------"
echo ">> Kiem tra cau hinh Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "=> Cau hinh Hop le. Reloading Nginx..."
    systemctl reload nginx
    echo "========================================================"
    echo "   HOAN TAT! Da xu ly xong."
    echo "========================================================"
else
    echo ">>> LOI: Nginx config bi loi. Vui long kiem tra output."
    exit 1
fi
