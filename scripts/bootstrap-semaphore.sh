#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEM_DIR="$ROOT_DIR/infra/semaphore"
ENV_FILE="$SEM_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$SEM_DIR/.env.example" "$ENV_FILE"
  echo "[INFO] $ENV_FILE a été créé."
  echo "[ACTION] Change au minimum SEMAPHORE_ADMIN_PASSWORD puis relance :"
  echo "         nano $ENV_FILE"
  exit 2
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

cd "$SEM_DIR"
docker compose --env-file .env up -d

echo "Semaphore démarré."
docker compose ps
echo "URL : http://IP_PUBLIQUE_DE_LA_VM:${SEMAPHORE_PORT:-3000}"
echo "Utilisateur : valeur SEMAPHORE_ADMIN dans infra/semaphore/.env"
