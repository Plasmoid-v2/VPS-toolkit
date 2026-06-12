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
BACKUP_FILE="${BACKUP_DIR}/99-bbr-vps-toolkit.conf.$(date +%F-%H%M%S).bak"

if ! sysctl net.ipv4.tcp_available_congestion_control 2>/dev/null | grep -qw bbr; then
    echo "BBR is not available in this kernel."
    exit 1
fi

"${SUDO[@]}" mkdir -p "$BACKUP_DIR"
if [ -f "$SYSCTL_FILE" ]; then
    "${SUDO[@]}" cp "$SYSCTL_FILE" "$BACKUP_FILE"
fi

"${SUDO[@]}" tee "$SYSCTL_FILE" > /dev/null <<'EOF'
# Managed by VPS-toolkit
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

"${SUDO[@]}" sysctl --system

sysctl net.core.default_qdisc
sysctl net.ipv4.tcp_congestion_control

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " BBR TCP congestion control enabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
