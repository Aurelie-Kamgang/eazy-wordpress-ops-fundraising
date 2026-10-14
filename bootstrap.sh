#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  wordpress)
    exec "$ROOT_DIR/scripts/bootstrap-wordpress.sh"
    ;;
  semaphore)
    exec "$ROOT_DIR/scripts/bootstrap-semaphore.sh"
    ;;
  check)
    exec "$ROOT_DIR/scripts/check-wordpress.sh"
    ;;
  *)
    cat <<USAGE
Usage:
  ./bootstrap.sh wordpress   # démarrer/installer WordPress + MySQL
  ./bootstrap.sh check       # vérifier WordPress/MySQL/plugins
  ./bootstrap.sh semaphore   # démarrer Semaphore
USAGE
    exit 1
    ;;
esac
