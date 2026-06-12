#!/usr/bin/env bash
set -e

# Создаём/обновляем security-check.sh, добавляем права, лог и cron-задачу на ежедневный запуск в 09:00
sudo tee /usr/local/bin/security-check.sh > /dev/null <<'EOF'
#!/usr/bin/env bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

CHECK_PERIOD_LABEL="last 7 days"
CHECK_PERIOD_SINCE="7 days ago"

# Цвета включаются только при ручном запуске в терминале
if [ -t 1 ] || [ "${FORCE_COLOR:-0}" = "1" ]; then
    RESET=$'\033[0m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    RED=$'\033[31m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    BLUE=$'\033[34m'
    CYAN=$'\033[36m'
else
    RESET=""
    BOLD=""
    DIM=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
fi

section() {
    echo
    printf "%b\n" "${BLUE}${BOLD}==== $1 ====${RESET}"
}

kv() {
    printf "%b%-28s%b %b\n" "${CYAN}" "$1" "${RESET}" "$2"
}

# Автоматически определяем SSH-порт из активной конфигурации sshd
SSH_PORTS="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2}' | sort -n -u)"
[ -z "$SSH_PORTS" ] && SSH_PORTS="22"

section "Security check"
kv "Completed at:" "${BOLD}$(date)${RESET}"
kv "Period:" "${YELLOW}${CHECK_PERIOD_LABEL}${RESET}"
kv "SSH port(s):" "${GREEN}${SSH_PORTS}${RESET}"

section "Failed SSH attempts in ${CHECK_PERIOD_LABEL}"
FAILED_SSH="$(journalctl --since "$CHECK_PERIOD_SINCE" --no-pager 2>/dev/null | grep -c "Failed password" || true)"

if [ "$FAILED_SSH" -eq 0 ]; then
    kv "Failed attempts:" "${GREEN}${FAILED_SSH}${RESET}"
else
    kv "Failed attempts:" "${RED}${FAILED_SSH}${RESET}"
fi

section "Fail2Ban status"

if command -v fail2ban-client >/dev/null 2>&1; then
    fail2ban-client status sshd 2>&1 | sed -e 's/`-/\\-/g' -e 's/`/\\/g' -e 's/^/  /'
else
    kv "Fail2Ban:" "${RED}not installed${RESET}"
fi

section "SSH listeners and connections"

for port in $SSH_PORTS; do
    kv "Checking port:" "${YELLOW}${port}${RESET}"

    LISTENERS="$(ss -tuln | awk -v p=":$port" '$0 ~ p"[[:space:]]" {print}')"
    if [ -n "$LISTENERS" ]; then
        kv "Listener:" "${GREEN}active${RESET}"
        echo "$LISTENERS" | sed 's/^/  /'
    else
        kv "Listener:" "${RED}not found${RESET}"
    fi

    CONNECTIONS="$(ss -tn state established | awk -v p=":$port" '$4 ~ p"$" || $5 ~ p"$" {print}')"
    if [ -n "$CONNECTIONS" ]; then
        kv "Active connections:" "${GREEN}found${RESET}"
        echo "$CONNECTIONS" | sed 's/^/  /'
    else
        kv "Active connections:" "${DIM}none${RESET}"
    fi
done

section "Available updates"

UPDATES="$(apt list --upgradable 2>/dev/null | grep -v '^Listing' || true)"
if [ -z "$UPDATES" ]; then
    kv "Upgradable packages:" "${GREEN}0${RESET}"
else
    echo "$UPDATES" | sed 's/^/  /'
    kv "Total:" "${YELLOW}$(echo "$UPDATES" | wc -l)${RESET}"
fi

echo
EOF

sudo chmod +x /usr/local/bin/security-check.sh
sudo touch /var/log/security-check.log
sudo chmod 644 /var/log/security-check.log

# Добавляем cron-задачу без дублей
( sudo crontab -l 2>/dev/null | grep -Fv '/usr/local/bin/security-check.sh' ; echo '0 9 * * * /usr/local/bin/security-check.sh >> /var/log/security-check.log 2>&1' ) | sudo crontab -

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " SSH security monitoring configured successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
