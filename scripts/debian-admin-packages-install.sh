#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Определяем, нужен ли sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Обновляем список пакетов
$SUDO apt update

# Обновляем установленные пакеты
$SUDO apt upgrade -y

# Устанавливаем расширенный админский набор без tmux и geoip-bin
$SUDO apt install -y \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    git \
    nano \
    less \
    cron \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges \
    lsof \
    jq \
    dnsutils \
    netcat-openbsd \
    socat \
    htop \
    rsync \
    fastfetch \
    ranger

# Выводим сообщение об успешном выполнении в зелёной рамке
echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Debian admin package set installed successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
