#!/bin/bash

echo "=========================================="
echo "Настройка ISP (Интернет-провайдер)"
echo "=========================================="

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт с правами root (sudo)"
    exit 1
fi

# Настройка сетевых интерфейсов
echo "Настройка сетевых интерфейсов..."

# ens33 - внешний интерфейс (к интернету)
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 << EOF
TYPE=Ethernet
BOOTPROTO=dhcp
NAME=ens33
DEVICE=ens33
ONBOOT=yes
EOF

# ens34 - к HQ-RTR (192.168.100.1/30)
cat > /etc/sysconfig/network-scripts/ifcfg-ens34 << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=ens34
DEVICE=ens34
ONBOOT=yes
IPADDR=192.168.100.1
NETMASK=255.255.255.252
EOF

# ens35 - к BR-RTR (192.168.200.1/30)
cat > /etc/sysconfig/network-scripts/ifcfg-ens35 << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=ens35
DEVICE=ens35
ONBOOT=yes
IPADDR=192.168.200.1
NETMASK=255.255.255.252
EOF

# Включение IP forwarding
echo "Включение IP forwarding..."
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ip-forward.conf
sysctl -p /etc/sysctl.d/99-ip-forward.conf

# Настройка NAT
echo "Настройка NAT..."
dnf install -y iptables-services

# Включаем NAT для внутренних сетей
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
iptables -A FORWARD -i ens34 -j ACCEPT
iptables -A FORWARD -i ens35 -j ACCEPT
iptables -A FORWARD -o ens33 -j ACCEPT

# Сохраняем правила iptables
iptables-save > /etc/sysconfig/iptables

# Включаем автозапуск iptables
systemctl enable iptables
systemctl start iptables

# Перезапуск сети
echo "Перезапуск сетевых интерфейсов..."
systemctl restart NetworkManager

echo "=========================================="
echo "Настройка ISP завершена!"
echo "Перезагрузите систему: sudo reboot"
echo "=========================================="
