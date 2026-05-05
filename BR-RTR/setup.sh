#!/bin/bash

echo "=========================================="
echo "Настройка BR-RTR (Маршрутизатор филиала)"
echo "=========================================="

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт с правами root (sudo)"
    exit 1
fi

# Настройка сетевых интерфейсов
echo "Настройка сетевых интерфейсов..."

# ens33 - к ISP (192.168.200.2/30)
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=ens33
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.200.2
NETMASK=255.255.255.252
GATEWAY=192.168.200.1
DNS1=192.168.200.1
EOF

# ens34 - внутренняя сеть BR (172.16.0.1/24)
cat > /etc/sysconfig/network-scripts/ifcfg-ens34 << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=ens34
DEVICE=ens34
ONBOOT=yes
IPADDR=172.16.0.1
NETMASK=255.255.255.0
EOF

# Включение IP forwarding
echo "Включение IP forwarding..."
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ip-forward.conf
sysctl -p /etc/sysctl.d/99-ip-forward.conf

# Установка и настройка FRR для динамической маршрутизации
echo "Установка FRR..."
dnf install -y frr

# Включаем демоны FRR
sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons
sed -i 's/ripd=no/ripd=yes/' /etc/frr/daemons

# Настройка статических маршрутов к главному офису
echo "Настройка маршрутизации..."
cat > /etc/sysconfig/network-scripts/route-ens33 << EOF
192.168.100.0/30 via 192.168.200.1 dev ens33
10.0.0.0/24 via 192.168.200.1 dev ens33
EOF

# Настройка firewall
echo "Настройка firewall..."
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Включаем автозапуск FRR
systemctl enable frr
systemctl start frr

# Перезапуск сети
echo "Перезапуск сетевых интерфейсов..."
systemctl restart NetworkManager

echo "=========================================="
echo "Настройка BR-RTR завершена!"
echo "Перезагрузите систему: sudo reboot"
echo "=========================================="
