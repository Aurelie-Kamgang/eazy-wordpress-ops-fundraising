#!/usr/bin/env bash
set -euo pipefail

echo "=== Docker containers ==="
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

echo
echo "=== MySQL health ==="
docker inspect eazy-wp-db --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}'

echo
echo "=== WordPress version ==="
docker exec eazy-wp-wordpress wp core version --allow-root

echo
echo "=== Plugins ==="
docker exec eazy-wp-wordpress wp plugin list --allow-root
