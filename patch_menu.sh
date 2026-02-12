#!/bin/bash

# Script: patch_menu.sh
# Mota: Them Redis Manager vao menu chinh cua HostVN Script
# Tac gia: Antigravity

TARGET="/var/hostvn/server-manager/routes/main_menu.sh"

if [ ! -f "$TARGET" ]; then
    echo "❌ Khong tim thay file menu tai: $TARGET"
    echo "⚠️ Bo qua buoc patch menu."
    exit 0
fi

# Kiem tra xem da patch chua
if grep -q "Redis Manager" "$TARGET"; then
    echo "✅ Menu da co Redis Manager. Khong can patch lai."
    exit 0
fi

echo ">> Dang backup file menu..."
cp "$TARGET" "$TARGET.bak"

echo ">> Dang them Redis Manager vao menu..."

# 1. Them hien thi menu (Insert before Option 0)
# Tim dong chua "0. ... Thoat" de chen Redis Menu truoc do
# Pattern: echo "...0....Thoat..."
sed -i '/echo ".*0\..*Thoat.*"/i \        echo "${BLUE}10. Redis Manager${NC}"' "$TARGET"

# 2. Them chuc nang vao case statement (Insert before Case 0)
# Tim dong case 0) ... exit 0 ;;
sed -i '/0).*exit 0 ;;/i \            10) /usr/local/bin/redis-manager ;;' "$TARGET"

echo "✅ Da them Redis Manager vao menu HostVN thanh cong!"
echo "👉 Ban co the go 'hostvn' hoac 'menu' de kiem tra."
