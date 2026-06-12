# VPS-toolkit

[English](README.md)

Небольшой набор Bash-скриптов для быстрой настройки VPS, базового hardening, мониторинга и self-hosted сервисов.

## Скрипты

| Скрипт | Назначение |
|---|---|
| `apt-auto-upgrades.sh` | Настраивает автоматические security-обновления APT |
| `bbr-enable.sh` | Включает TCP congestion control BBR |
| `bbr-disable.sh` | Отключает BBR и восстанавливает не-BBR режим |
| `debian-admin-packages-install.sh` | Устанавливает расширенный админский набор пакетов для Debian |
| `docker-debian-setup.sh` | Устанавливает Docker Engine и Docker Compose plugin на Debian |
| `fail2ban-setup.sh` | Устанавливает и настраивает Fail2Ban для SSH |
| `hostname-change.sh` | Меняет hostname и обновляет `/etc/hosts` |
| `ip-quality-check.sh` | Проверяет качество и репутацию IP-адреса |
| `rustdesk-server-setup.sh` | Разворачивает RustDesk Server через Docker Compose |
| `security-check-setup.sh` | Устанавливает ежедневный SSH/security мониторинг с логами |
| `speedtest-cli.sh` | Устанавливает и запускает Ookla Speedtest CLI |
| `ssh-port-change.sh` | Меняет SSH-порт, добавляет UFW limit-правило и обновляет Fail2Ban |
| `ufw-basic-setup.sh` | Применяет минимальные правила UFW и включает firewall |
| `ufw-disable-ping.sh` | Отключает входящий ping через UFW |
| `ufw-enable-ping.sh` | Включает входящий ping обратно через UFW |
| `vps-basic-setup.sh` | Запускает полный базовый деплой VPS одной командой |

## Быстрый базовый деплой VPS

Скрипт быстрого старта запускает полный базовый деплой нового Debian VPS.

Он принимает два аргумента:

| Аргумент | Значение | Пример |
|---|---|---|
| `NEW_HOSTNAME` | Желаемое имя хоста | `ordinary-coffee` |
| `NEW_SSH_PORT` | Желаемый SSH-порт | `41337` |

Запуск:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

Что запускает скрипт:

| Порядок | Скрипт | Действие |
|---:|---|---|
| 1 | `debian-admin-packages-install.sh` | Устанавливает базовый админский набор пакетов Debian |
| 2 | `hostname-change.sh` | Меняет hostname и обновляет `/etc/hosts` |
| 3 | `apt-auto-upgrades.sh` | Включает автоматические security-обновления APT |
| 4 | `ssh-port-change.sh` | Меняет SSH-порт и добавляет UFW `LIMIT`-правило |
| 5 | `ufw-basic-setup.sh` | Применяет минимальные правила UFW и включает firewall |
| 6 | `fail2ban-setup.sh` | Устанавливает и настраивает Fail2Ban для SSH |
| 7 | `security-check-setup.sh` | Устанавливает ежедневный SSH/security мониторинг |
| 8 | `bbr-enable.sh` | Включает TCP congestion control BBR |
| 9 | `ufw-disable-ping.sh` | Отключает входящий ping |

Этот скрипт рассчитан на быстрый доверенный первичный сетап, когда базовый порядок деплоя уже известен и проверен. После завершения нужно подключаться по новому SSH-порту.

## Использование

Замени `SCRIPT_NAME.sh` на нужный скрипт:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

## Смена SSH-порта

Скрипт смены SSH-порта требует номер порта как аргумент:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

Что делает скрипт:

| Шаг | Действие |
|---|---|
| Проверка порта | Проверяет, что аргумент является портом от `1` до `65535` |
| Backup | Сохраняет backup SSH-конфигов в `/etc/ssh/vps-toolkit-backups/` |
| SSH config | Записывает новый порт в `/etc/ssh/sshd_config.d/99-vps-toolkit-port.conf` |
| UFW | Добавляет `LIMIT`-правило для нового SSH-порта с комментом `SSH with basic brutforce protection` |
| Проверка | Выполняет `sshd -t` перед применением |
| Reload | Перезагружает SSH без закрытия текущей сессии |
| Fail2Ban | Обновляет `/etc/fail2ban/jail.d/sshd.local`, если файл существует |

Скрипт не удаляет старые UFW-правила автоматически.

## Базовая настройка UFW

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/ufw-basic-setup.sh | sudo bash
```

Запускай его только после того, как SSH-доступ уже разрешён: через `ssh-port-change.sh` или вручную.

Что делает скрипт:

| Шаг | Действие |
|---|---|
| Incoming policy | Выполняет `sudo ufw default deny incoming` |
| Outgoing policy | Выполняет `sudo ufw default allow outgoing` |
| Enable firewall | Выполняет `sudo ufw --force enable` |
| Status check | Показывает `sudo ufw status numbered` |

## Запуск скриптов

```bash
# Запустить полный базовый деплой VPS одной командой
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337

# Установить расширенный админский набор пакетов для Debian
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/debian-admin-packages-install.sh | sudo bash

# Сменить SSH-порт, добавить UFW limit-правило и обновить Fail2Ban
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337

# Применить минимальные правила UFW и включить firewall
curl -fsSL https://raw.githubusercontent.com/Plasmoid-v2/VPS-toolkit/main/scripts/ufw-basic-setup.sh | sudo bash
```

## Примечания

Скрипты рассчитаны на Debian-based VPS.
