#!/usr/bin/env bash
set -e

# Проверяем качество и “чистоту” IP-адреса сервера
bash <(curl -Ls https://IP.Check.Place) -l en -p -y
