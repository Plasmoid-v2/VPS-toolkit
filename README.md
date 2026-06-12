# VPS-toolkit

[Русский](README.ru.md)

A collection of Bash scripts for initial Debian VPS setup, hardening, monitoring, diagnostics, and self-hosted services.

## Scripts

| Script | Purpose |
|---|---|
| `apt-auto-upgrades.sh` | Configure automatic APT security updates |
| `bbr-enable.sh` | Enable BBR TCP congestion control |
| `bbr-disable.sh` | Disable BBR TCP congestion control |
| `debian-admin-packages-install.sh` | Install an extended admin package set for Debian |
| `docker-debian-setup.sh` | Install Docker Engine and Docker Compose plugin |
| `fail2ban-setup.sh` | Install and configure Fail2Ban |
| `hostname-change.sh` | Change system hostname and update `/etc/hosts` |
| `ip-quality-check.sh` | Check IP address quality and reputation |
| `rustdesk-server-setup.sh` | Deploy RustDesk Server with Docker Compose |
| `security-check-setup.sh` | Install daily security monitoring script with logs |
| `speedtest-cli.sh` | Install and run Ookla Speedtest CLI |
| `ssh-port-change.sh` | Change the server login port and add a UFW limit rule |
| `ufw-basic-setup.sh` | Apply minimal UFW defaults and enable firewall |
| `ufw-disable-ping.sh` | Disable incoming ping through UFW rules |
| `ufw-enable-ping.sh` | Enable incoming ping back through UFW rules |
| `vps-basic-setup.sh` | Run the full basic VPS deployment sequence |

## Quick setup

`vps-basic-setup.sh` runs the standard basic deployment flow and accepts two arguments: hostname and login port.

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

It runs the base package installer, hostname change, APT security updates, login port change, UFW setup, Fail2Ban setup, security check setup, BBR setup, and ping disabling.

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

## Notes

These scripts are intended for Debian-based VPS servers.
