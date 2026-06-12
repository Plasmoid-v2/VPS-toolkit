#!/usr/bin/env bash
set -e

# Создаём рабочую директорию RustDesk Server
mkdir -p ~/rustdeskdocker
cd ~/rustdeskdocker

# Создаём docker-compose.yml с двумя сервисами: hbbs — ID/signaling, hbbr — relay
cat > docker-compose.yml <<'EOF'
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    network_mode: "host"
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    network_mode: "host"
    restart: unless-stopped
EOF

# Открываем минимально необходимые порты RustDesk
sudo ufw allow 21115/tcp   # RustDesk NAT type test
sudo ufw allow 21116/tcp   # RustDesk TCP hole punching / connection service
sudo ufw allow 21116/udp   # RustDesk ID registration / heartbeat
sudo ufw allow 21117/tcp   # RustDesk relay service

# Запускаем RustDesk Server
docker compose up -d

# Проверяем контейнеры
docker compose ps

# Показываем публичный ключ сервера синим цветом, его нужно вставить в клиенты RustDesk
echo
printf '\033[1;34m%s\033[0m\n' "===== RustDesk server public key ====="
printf '\033[1;34m%s\033[0m\n' "$(cat ./data/id_ed25519.pub)"
printf '\033[1;34m%s\033[0m\n' "======================================"
