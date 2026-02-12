#!/bin/bash

# Script: redis_manager.sh
# Mota: Menu quan ly Redis Server don gian cho HostVN VPS
# Tac gia: Antigravity

# Kiem tra quyen root
if [ "$EUID" -ne 0 ]; then
  echo "Vui long chay script voi quyen root!"
  exit 1
fi

REDIS_SERVICE="redis-server"

show_menu() {
    clear
    echo "========================================================"
    echo "   REDIS MANAGER - QUAN LY REDIS"
    echo "========================================================"
    echo "1. Khoi dong lai Redis (Restart)"
    echo "2. Dung Redis (Stop)"
    echo "3. Bat Redis (Start)"
    echo "4. Kiem tra trang thai (Status)"
    echo "5. Bat tu dong khoi dong theo VPS (Enable)"
    echo "6. Tat tu dong khoi dong (Disable)"
    echo "--------------------------------------------------------"
    echo "0. Thoat"
    echo "========================================================"
}

while true; do
    show_menu
    read -p "Chon chuc nang [0-6]: " choice
    case $choice in
        1)
            echo ">> Dang restart Redis..."
            systemctl restart $REDIS_SERVICE
            echo ">> Xong."
            read -p "Nhan Enter de tiep tuc..."
            ;;
        2)
            echo ">> Dang dung Redis..."
            systemctl stop $REDIS_SERVICE
            echo ">> Xong."
            read -p "Nhan Enter de tiep tuc..."
            ;;
        3)
            echo ">> Dang bat Redis..."
            systemctl start $REDIS_SERVICE
            echo ">> Xong."
            read -p "Nhan Enter de tiep tuc..."
            ;;
        4)
            echo ">> Trang thai Redis:"
            systemctl status $REDIS_SERVICE --no-pager
            read -p "Nhan Enter de tiep tuc..."
            ;;
        5)
            echo ">> Bat tu dong khoi dong..."
            systemctl enable $REDIS_SERVICE
            echo ">> Xong."
            read -p "Nhan Enter de tiep tuc..."
            ;;
        6)
            echo ">> Tat tu dong khoi dong..."
            systemctl disable $REDIS_SERVICE
            echo ">> Xong."
            read -p "Nhan Enter de tiep tuc..."
            ;;
        0)
            echo "Tam biet!"
            exit 0
            ;;
        *)
            echo "Lua chon khong hop le!"
            read -p "Nhan Enter de thu lai..."
            ;;
    esac
done
