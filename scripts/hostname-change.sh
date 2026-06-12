#!/usr/bin/env bash
set -e

# Берём новое имя хоста из первого аргумента
NEW_HOSTNAME="${1:-}"

# Если аргумент не передан — показываем пример использования и выходим
if [ -z "$NEW_HOSTNAME" ]; then
    echo "Usage: hostname-change.sh NEW_HOSTNAME"
    echo "Example: hostname-change.sh ordinary-coffee"
    exit 1
fi

# Проверяем, что hostname состоит только из допустимых символов
if ! echo "$NEW_HOSTNAME" | grep -Eq '^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$'; then
    echo "Invalid hostname: $NEW_HOSTNAME"
    echo "Use letters, numbers, dots or hyphens. Do not start or end with dot/hyphen."
    exit 1
fi

# Задаём новое имя хоста
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Обновляем локальную запись hostname в /etc/hosts
sudo sed -i "/^127.0.1.1/d" /etc/hosts
echo "127.0.1.1 $NEW_HOSTNAME" | sudo tee -a /etc/hosts > /dev/null

# Проверяем результат
hostnamectl status
hostname
grep "127.0.1.1" /etc/hosts

# Выводим сообщение об успешном выполнении в зелёной рамке
echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Hostname changed successfully to: $NEW_HOSTNAME"
printf '\033[1;32m%s\033[0m\n' "============================================================"
