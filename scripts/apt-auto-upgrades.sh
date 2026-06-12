#!/usr/bin/env bash
set -e

# Устанавливаем unattended-upgrades, если ещё не установлен
sudo apt install -y unattended-upgrades

# Настраиваем поведение автоматических обновлений безопасности
sudo tee /etc/apt/apt.conf.d/52unattended-upgrades-local > /dev/null <<'EOF'
Unattended-Upgrade::Automatic-Reboot "false";  // сервер не будет сам перезагружаться после обновлений
Unattended-Upgrade::Remove-Unused-Dependencies "true";  // ненужные зависимости будут удаляться автоматически
EOF

# Включаем ежедневное обновление списка пакетов, автоустановку обновлений и очистку apt-кэша
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";  // ежедневно обновлять список пакетов, аналог apt update
APT::Periodic::Unattended-Upgrade "1";  // ежедневно запускать автоматическую установку доступных обновлений
APT::Periodic::AutocleanInterval "7";  // очищать apt-кэш раз в 7 дней
EOF

# Применяем/активируем unattended-upgrades в noninteractive-режиме
sudo dpkg-reconfigure -fnoninteractive unattended-upgrades

# Проверяем systemd-таймеры apt
systemctl list-timers 'apt-daily*' --no-pager

# Проверяем конфигурацию без реальной установки обновлений
sudo unattended-upgrade --dry-run --debug

# Выводим сообщение об успешном выполнении в зелёной рамке
echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Automatic APT security updates configured successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
