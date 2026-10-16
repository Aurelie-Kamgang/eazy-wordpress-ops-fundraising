#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

KEY="${1:-}"
if [[ -z "$KEY" ]]; then
  echo "Usage: $0 /chemin/vers/cle_privee"
  echo "Ce test est lancé depuis la VM, pas depuis le conteneur Semaphore."
  echo "Il valide surtout l'inventaire SSH et l'utilisateur ubuntu."
  exit 2
fi

ansible -i inventory/semaphore.yml wordpress_servers -m ping --private-key "$KEY"
ansible-playbook -i inventory/semaphore.yml site.yml --tags check --private-key "$KEY"
