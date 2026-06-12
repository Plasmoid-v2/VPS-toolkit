#!/usr/bin/env bash
set -e

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Определяем, нужен ли sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
else
    SUDO=(sudo)
fi

# Проверяем, что UFW установлен
if ! command -v ufw >/dev/null 2>&1; then
    echo "UFW is not installed."
    echo "Install it first or run debian-admin-packages-install.sh."
    exit 1
fi

# Запрещаем все входящие подключения по умолчанию
"${SUDO[@]}" ufw default deny incoming

# Разрешаем все исходящие подключения по умолчанию
"${SUDO[@]}" ufw default allow outgoing

# Включаем UFW без интерактивного подтверждения
"${SUDO[@]}" ufw --force enable

# Показываем итоговые правила
"${SUDO[@]}" ufw status numbered

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Basic UFW firewall setup completed successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
