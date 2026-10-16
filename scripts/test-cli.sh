#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/3] Ping local VM"
ansible -i inventory/local.yml wordpress_servers -m ping

echo "[2/3] Check target"
ansible-playbook -i inventory/local.yml site.yml --tags check

echo "[3/3] List tags"
ansible-playbook -i inventory/local.yml site.yml --list-tags

echo "OK : le contexte CLI local est prêt."
