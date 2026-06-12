#!/usr/bin/env bash
set -e

# Устанавливаем зависимости для подключения Docker-репозитория
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Создаём директорию для APT keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Скачиваем официальный GPG-ключ Docker
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

# Даём APT право читать GPG-ключ Docker
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Добавляем официальный Docker APT-репозиторий для текущей версии Debian
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновляем список пакетов уже с Docker-репозиторием
sudo apt-get update

# Устанавливаем Docker Engine, CLI, containerd, Buildx и Docker Compose plugin
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Включаем Docker в автозагрузку и запускаем службу
sudo systemctl enable --now docker

# Проверяем статус Docker без зависания в pager
sudo systemctl status docker --no-pager

# Проверяем установку тестовым контейнером
sudo docker run hello-world

# Выводим сообщение об успешном выполнении в зелёной рамке
echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Docker Engine and Docker Compose plugin installed successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
