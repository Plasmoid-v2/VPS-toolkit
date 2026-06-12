#!/usr/bin/env bash
set -e

# Запрещаем входящий IPv4 ping, не трогая остальные ICMP-типы
sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# Запрещаем входящий IPv6 ping, не ломая остальные ICMPv6-типы
sudo sed -i 's/-A ufw6-before-input -p icmpv6 --icmpv6-type echo-request -j ACCEPT/-A ufw6-before-input -p icmpv6 --icmpv6-type echo-request -j DROP/' /etc/ufw/before6.rules

# Перезагружаем UFW без полного disable/enable
sudo ufw reload

# Проверяем статус UFW
sudo ufw status numbered

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Incoming ping has been disabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
