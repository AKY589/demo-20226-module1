#!/bin/bash

echo "=========================================="
echo "Настройка HQ-SRV (Сервер главного офиса)"
echo "=========================================="

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт с правами root (sudo)"
    exit 1
fi

# Настройка сетевого интерфейса
echo "Настройка сетевого интерфейса..."

# ens33 - внутренняя сеть HQ (10.0.0.2/24)
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=ens33
DEVICE=ens33
ONBOOT=yes
IPADDR=10.0.0.2
NETMASK=255.255.255.0
GATEWAY=10.0.0.1
DNS1=10.0.0.2
EOF

# Установка необходимых пакетов
echo "Установка пакетов..."
dnf install -y bind bind-utils httpd dhcp-server

# Настройка DNS (BIND)
echo "Настройка DNS сервера..."
cp /etc/named.conf /etc/named.conf.backup

cat > /etc/named.conf << 'EOF'
options {
    listen-on port 53 { 127.0.0.1; 10.0.0.2; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query { any; };
    recursion yes;
    forwarders { 8.8.8.8; 8.8.4.4; };
};

zone "hq.demo.local" IN {
    type master;
    file "hq.demo.local.zone";
};

zone "0.0.10.in-addr.arpa" IN {
    type master;
    file "10.0.0.rev";
};
EOF

# Создание прямой зоны DNS
cat > /var/named/hq.demo.local.zone << EOF
\$TTL 86400
@   IN  SOA     hq-srv.hq.demo.local. admin.hq.demo.local. (
                2026050501  ; Serial
                3600        ; Refresh
                1800        ; Retry
                604800      ; Expire
                86400 )     ; Minimum TTL

@       IN  NS      hq-srv.hq.demo.local.
hq-srv  IN  A       10.0.0.2
hq-rtr  IN  A       10.0.0.1
hq-cli  IN  A       10.0.0.10
www     IN  A       10.0.0.2
EOF

# Создание обратной зоны DNS
cat > /var/named/10.0.0.rev << EOF
\$TTL 86400
@   IN  SOA     hq-srv.hq.demo.local. admin.hq.demo.local. (
                2026050501  ; Serial
                3600        ; Refresh
                1800        ; Retry
                604800      ; Expire
                86400 )     ; Minimum TTL

@       IN  NS      hq-srv.hq.demo.local.
2       IN  PTR     hq-srv.hq.demo.local.
1       IN  PTR     hq-rtr.hq.demo.local.
10      IN  PTR     hq-cli.hq.demo.local.
EOF

chown named:named /var/named/hq.demo.local.zone
chown named:named /var/named/10.0.0.rev

# Настройка DHCP сервера
echo "Настройка DHCP сервера..."
cat > /etc/dhcp/dhcpd.conf << EOF
option domain-name "hq.demo.local";
option domain-name-servers 10.0.0.2;
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 10.0.0.0 netmask 255.255.255.0 {
    range 10.0.0.10 10.0.0.50;
    option routers 10.0.0.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 10.0.0.2;
}
EOF

# Настройка веб-сервера Apache
echo "Настройка веб-сервера..."
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>HQ Server - DEMO 2026</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Добро пожаловать на HQ-SRV</h1>
    <p>Сервер главного офиса - ДЕМО 2026 Модуль 1</p>
    <p>IP: 10.0.0.2</p>
</body>
</html>
EOF

# Настройка firewall
echo "Настройка firewall..."
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-service=dhcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Включение и запуск сервисов
echo "Запуск сервисов..."
systemctl enable named
systemctl start named

systemctl enable dhcpd
systemctl start dhcpd

systemctl enable httpd
systemctl start httpd

# Перезапуск сети
echo "Перезапуск сетевого интерфейса..."
systemctl restart NetworkManager

echo "=========================================="
echo "Настройка HQ-SRV завершена!"
echo "Сервисы: DNS, DHCP, HTTP"
echo "Перезагрузите систему: sudo reboot"
echo "=========================================="
