#!/bin/bash

echo "=========================================="
echo "Настройка HQ-CLI (Клиент главного офиса)"
echo "=========================================="

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт с правами root (sudo)"
    exit 1
fi

# Настройка сетевого интерфейса
echo "Настройка сетевого интерфейса..."

# ens33 - внутренняя сеть HQ (получение IP по DHCP)
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 << EOF
TYPE=Ethernet
BOOTPROTO=dhcp
NAME=ens33
DEVICE=ens33
ONBOOT=yes
EOF

# Установка базовых пакетов
echo "Установка пакетов..."
dnf install -y bind-utils curl wget

# Настройка firewall
echo "Настройка firewall..."
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Перезапуск сети
echo "Перезапуск сетевого интерфейса..."
systemctl restart NetworkManager

echo "=========================================="
echo "Настройка HQ-CLI завершена!"
echo "IP адрес будет получен по DHCP от HQ-SRV"
echo "Перезагрузите систему: sudo reboot"
echo "=========================================="
