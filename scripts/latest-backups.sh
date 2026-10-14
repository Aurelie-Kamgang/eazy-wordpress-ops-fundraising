#!/usr/bin/env bash
set -euo pipefail
BASE="/var/backups/eazytraining/wordpress"
echo "=== Database backups ==="
sudo ls -lht "$BASE/database" 2>/dev/null | head -10 || true
echo
echo "=== Files backups ==="
sudo ls -lht "$BASE/files" 2>/dev/null | head -10 || true
