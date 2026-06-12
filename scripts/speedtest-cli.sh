#!/usr/bin/env bash
set -e

# Устанавливаем curl для загрузки install-скрипта
sudo apt install -y curl

# Подключаем официальный репозиторий Ookla Speedtest CLI
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

# Устанавливаем Speedtest CLI
sudo apt install -y speedtest

# Запускаем speedtest без интерактивного подтверждения лицензии/GDPR
speedtest --accept-license --accept-gdpr
