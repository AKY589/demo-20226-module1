# Быстрый старт

## Порядок настройки машин

**ВАЖНО**: Настраивайте машины в следующем порядке:

1. **ISP** (сначала настроить провайдера)
2. **HQ-RTR** и **BR-RTR** (маршрутизаторы)
3. **HQ-SRV** и **BR-SRV** (серверы)
4. **HQ-CLI** (клиент последним)

## Команды для каждой машины

### 1. ISP
```bash
cd /path/to/demo-2026-module1/ISP
sudo bash setup.sh
sudo reboot
```

### 2. HQ-RTR
```bash
cd /path/to/demo-2026-module1/HQ-RTR
sudo bash setup.sh
sudo reboot
```

### 3. HQ-SRV
```bash
cd /path/to/demo-2026-module1/HQ-SRV
sudo bash setup.sh
sudo reboot
```

### 4. HQ-CLI
```bash
cd /path/to/demo-2026-module1/HQ-CLI
sudo bash setup.sh
sudo reboot
```

### 5. BR-RTR
```bash
cd /path/to/demo-2026-module1/BR-RTR
sudo bash setup.sh
sudo reboot
```

### 6. BR-SRV
```bash
cd /path/to/demo-2026-module1/BR-SRV
sudo bash setup.sh
sudo reboot
```

## Проверка после настройки

### На HQ-CLI (после перезагрузки):
```bash
# Проверить IP адрес (должен быть из диапазона 10.0.0.10-50)
ip addr show ens33

# Проверить DNS
nslookup hq-srv.hq.demo.local

# Проверить веб-сервер
curl http://10.0.0.2

# Проверить связь с филиалом
ping 172.16.0.2
```

### На HQ-SRV:
```bash
# Проверить статус сервисов
systemctl status named
systemctl status dhcpd
systemctl status httpd

# Проверить DNS зоны
nslookup hq-srv.hq.demo.local 10.0.0.2
```

### На BR-SRV:
```bash
# Проверить статус сервисов
systemctl status named
systemctl status dhcpd
systemctl status httpd

# Проверить связь с главным офисом
ping 10.0.0.2
```

## Возможные проблемы

### Если DHCP не работает на HQ-CLI:
```bash
# Перезапустить сетевой интерфейс
sudo nmcli connection down ens33
sudo nmcli connection up ens33

# Или вручную запросить IP
sudo dhclient -r ens33
sudo dhclient ens33
```

### Если DNS не резолвит имена:
```bash
# Проверить /etc/resolv.conf
cat /etc/resolv.conf

# Должно быть:
# nameserver 10.0.0.2 (для HQ)
# nameserver 172.16.0.2 (для BR)
```

### Если нет связи между офисами:
```bash
# На ISP проверить IP forwarding
cat /proc/sys/net/ipv4/ip_forward
# Должно быть: 1

# Проверить NAT правила
sudo iptables -t nat -L -n -v
```

## Время выполнения

- Каждый скрипт выполняется ~2-5 минут
- Общее время настройки всех машин: ~15-20 минут
- После перезагрузки сеть готова к работе

## Примечания

- Все скрипты требуют прав root (sudo)
- Интернет нужен только при первом запуске (для установки пакетов)
- После перезагрузки все настройки сохраняются
- Скрипты идемпотентны (можно запускать повторно)
