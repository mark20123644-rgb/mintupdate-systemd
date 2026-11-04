#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/3] systemd user unit"
mkdir -p ~/.config/systemd/user
cp "$SCRIPT_DIR/systemd-user/mintupdate-autostart.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable mintupdate-autostart.service

echo "[2/3] XDG-заглушка"
mkdir -p ~/.config/autostart
cp "$SCRIPT_DIR/autostart/mintupdate.desktop" ~/.config/autostart/

echo "[3/3] Готово. Перезагрузитесь."
echo "  systemctl --user status mintupdate-autostart.service --no-pager"
echo "  pgrep -afi mintupdate"
