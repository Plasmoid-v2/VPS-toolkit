#!/usr/bin/env bash
set -e

# Устанавливаем Fail2Ban, создаём отдельную SSH-конфигурацию, автоопределяем SSH-порт, запускаем и проверяем
sudo apt install -y fail2ban

SSH_PORTS="$(sudo sshd -T 2>/dev/null | awk '$1 == "port" {print $2}' | sort -n -u | paste -sd, -)"
[ -z "$SSH_PORTS" ] && SSH_PORTS="22"

sudo tee /etc/fail2ban/jail.d/sshd.local > /dev/null <<EOF
[DEFAULT]
bantime = 3600  ; банит IP на 1 час
findtime = 600  ; смотрит попытки за последние 10 минут
maxretry = 3  ; бан после 3 неудачных попыток

[sshd]
enabled = true
port = ${SSH_PORTS}  ; берёт текущий SSH-порт из sshd, например 41337
filter = sshd
backend = systemd  ; читает SSH-логи через journalctl, без привязки к /var/log/auth.log
EOF

sudo fail2ban-client -t
sudo systemctl enable --now fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Fail2Ban SSH protection configured successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
