#!/usr/bin/env bash
set -e

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
BASE_URL="https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts"
NEW_HOSTNAME="${1:-}"
NEW_SSH_PORT="${2:-}"
BLUE_BOLD="\033[1;34m"
GREEN_BOLD="\033[1;32m"
RESET="\033[0m"

if [ -z "$NEW_HOSTNAME" ] || [ -z "$NEW_SSH_PORT" ]; then
    echo "Usage: vps-basic-setup.sh NEW_HOSTNAME NEW_SSH_PORT"
    echo "Example: vps-basic-setup.sh ordinary-coffee 41337"
    exit 1
fi

if ! echo "$NEW_HOSTNAME" | grep -Eq '^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$'; then
    echo "Invalid hostname: $NEW_HOSTNAME"
    exit 1
fi

if ! echo "$NEW_SSH_PORT" | grep -Eq '^[0-9]+$' || [ "$NEW_SSH_PORT" -lt 1 ] || [ "$NEW_SSH_PORT" -gt 65535 ]; then
    echo "Invalid SSH port: $NEW_SSH_PORT"
    exit 1
fi

step() {
    echo
    printf "${BLUE_BOLD}%s${RESET}\n" "===== $1 ====="
}

run_script() {
    curl -fsSL "${BASE_URL}/$1" | bash
}

run_script_with_args() {
    SCRIPT_NAME="$1"
    shift
    curl -fsSL "${BASE_URL}/${SCRIPT_NAME}" | bash -s -- "$@"
}

step "1. Installing Debian admin package set"
run_script "debian-admin-packages-install.sh"

step "2. Changing hostname"
run_script_with_args "hostname-change.sh" "$NEW_HOSTNAME"

step "3. Configuring automatic APT security updates"
run_script "apt-auto-upgrades.sh"

step "4. Changing SSH port and adding UFW LIMIT rule"
run_script_with_args "ssh-port-change.sh" "$NEW_SSH_PORT"

step "5. Enabling basic UFW firewall"
run_script "ufw-basic-setup.sh"

step "6. Installing and configuring Fail2Ban"
run_script "fail2ban-setup.sh"

step "7. Installing security-check monitoring"
run_script "security-check-setup.sh"

step "8. Enabling BBR"
run_script "bbr-enable.sh"

step "9. Disabling incoming ping"
run_script "ufw-disable-ping.sh"

echo
printf "${GREEN_BOLD}%s${RESET}\n" "============================================================"
printf "${GREEN_BOLD}%s${RESET}\n" " Basic VPS deployment completed successfully."
printf "${GREEN_BOLD}%s${RESET}\n" " Hostname: ${NEW_HOSTNAME}"
printf "${GREEN_BOLD}%s${RESET}\n" " SSH port: ${NEW_SSH_PORT}"
printf "${GREEN_BOLD}%s${RESET}\n" "============================================================"
