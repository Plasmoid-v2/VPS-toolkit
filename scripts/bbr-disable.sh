#!/usr/bin/env bash
set -e

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
else
    SUDO=(sudo)
fi

SYSCTL_FILE="/etc/sysctl.d/99-bbr-vps-toolkit.conf"
BACKUP_DIR="/etc/sysctl.d/vps-toolkit-backups"
BACKUP_FILE="${BACKUP_DIR}/99-bbr-vps-toolkit.conf.disabled.$(date +%F-%H%M%S).bak"

"${SUDO[@]}" mkdir -p "$BACKUP_DIR"

if [ -f "$SYSCTL_FILE" ]; then
    "${SUDO[@]}" cp "$SYSCTL_FILE" "$BACKUP_FILE"
    "${SUDO[@]}" rm -f "$SYSCTL_FILE"
fi

if sysctl net.ipv4.tcp_available_congestion_control 2>/dev/null | grep -qw cubic; then
    RESTORE_CC="cubic"
else
    RESTORE_CC="$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null | awk '{print $1}')"
fi

[ -z "$RESTORE_CC" ] && RESTORE_CC="cubic"

"${SUDO[@]}" tee /etc/sysctl.d/99-bbr-vps-toolkit-disable.conf > /dev/null <<EOF
# Managed by VPS-toolkit
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = ${RESTORE_CC}
EOF

"${SUDO[@]}" sysctl --system

sysctl net.core.default_qdisc
sysctl net.ipv4.tcp_congestion_control

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " BBR TCP congestion control disabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
