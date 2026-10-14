#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WP_DIR="$ROOT_DIR/infra/wordpress"
ENV_FILE="$WP_DIR/.env"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "[ERREUR] $1 n'est pas installé."; exit 1; }; }
need_cmd docker
docker compose version >/dev/null 2>&1 || { echo "[ERREUR] docker compose n'est pas disponible."; exit 1; }

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$WP_DIR/.env.example" "$ENV_FILE"
  echo "[INFO] $ENV_FILE a été créé."
  echo "[ACTION] Configure WORDPRESS_PUBLIC_URL et les mots de passe, puis relance :"
  echo "         nano $ENV_FILE"
  exit 2
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${WORDPRESS_THEME:=eazytraining-preprod}"
: "${BOOTSTRAP_PLUGIN:=give}"

if [[ -z "${WORDPRESS_PUBLIC_URL:-}" || "${WORDPRESS_PUBLIC_URL}" == *"YOUR_VM_PUBLIC_IP"* ]]; then
  echo "[ERREUR] WORDPRESS_PUBLIC_URL n'est pas configuré dans $ENV_FILE"
  echo "Exemple : WORDPRESS_PUBLIC_URL=http://54.162.233.250:${WORDPRESS_PORT:-8004}"
  exit 3
fi

echo "[INFO] URL WordPress : $WORDPRESS_PUBLIC_URL"
wp_exec() { docker exec eazy-wp-wordpress wp "$@" --allow-root; }
wp_page_id() { wp_exec post list --post_type=page --name="$1" --field=ID --format=ids 2>/dev/null | head -n1; }

cd "$WP_DIR"
echo "[1/9] Construction et démarrage de WordPress/MySQL..."
docker compose --env-file .env up -d --build

echo "[2/9] Attente de MySQL healthy..."
for i in $(seq 1 60); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' eazy-wp-db 2>/dev/null || true)"
  [[ "$status" == "healthy" ]] && break
  if [[ "$i" -eq 60 ]]; then docker logs --tail 100 eazy-wp-db || true; exit 4; fi
  sleep 3
done

echo "[3/9] Attente de WP-CLI..."
for i in $(seq 1 60); do
  if wp_exec core version >/dev/null 2>&1; then break; fi
  if [[ "$i" -eq 60 ]]; then docker logs --tail 100 eazy-wp-wordpress || true; exit 5; fi
  sleep 3
done

echo "[4/9] Installation WordPress si nécessaire..."
if ! wp_exec core is-installed >/dev/null 2>&1; then
  wp_exec core install \
    --url="$WORDPRESS_PUBLIC_URL" \
    --title="$WORDPRESS_SITE_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email
else
  echo "[INFO] WordPress est déjà installé : la base existante est conservée."
fi

wp_exec option update home "$WORDPRESS_PUBLIC_URL" >/dev/null
wp_exec option update siteurl "$WORDPRESS_PUBLIC_URL" >/dev/null
wp_exec rewrite structure '/%postname%/' >/dev/null || true
wp_exec rewrite flush >/dev/null || true

echo "[5/9] Synchronisation du thème avec le volume WordPress..."
docker exec eazy-wp-wordpress sh -c "
  test -d /usr/src/wordpress/wp-content/themes/$WORDPRESS_THEME || exit 11
  mkdir -p /var/www/html/wp-content/themes/$WORDPRESS_THEME
  cp -a /usr/src/wordpress/wp-content/themes/$WORDPRESS_THEME/. /var/www/html/wp-content/themes/$WORDPRESS_THEME/
  chown -R www-data:www-data /var/www/html/wp-content/themes/$WORDPRESS_THEME
"
wp_exec theme activate "$WORDPRESS_THEME" >/dev/null

echo "[6/9] Préparation de GiveWP sans écraser une version déjà installée..."
if ! wp_exec plugin is-installed "$BOOTSTRAP_PLUGIN" >/dev/null 2>&1; then
  docker exec eazy-wp-wordpress sh -c "
    test -d /usr/src/wordpress/wp-content/plugins/give || exit 12
    mkdir -p /var/www/html/wp-content/plugins/give
    cp -a /usr/src/wordpress/wp-content/plugins/give/. /var/www/html/wp-content/plugins/give/
    chown -R www-data:www-data /var/www/html/wp-content/plugins/give
  "
fi
wp_exec plugin activate "$BOOTSTRAP_PLUGIN" >/dev/null 2>&1 || true

# GiveWP crée ses pages système à l'activation. On ne touche pas aux dons/formulaires existants.
echo "[7/9] Ajout des pages métier si elles n'existent pas déjà..."
create_page_if_missing() {
  local slug="$1" title="$2" content="$3"
  local id
  id="$(wp_page_id "$slug")"
  if [[ -n "$id" ]]; then
    echo "[INFO] Page existante conservée : $title (ID $id)" >&2
    echo "$id"
  else
    wp_exec post create --post_type=page --post_status=publish --post_name="$slug" --post_title="$title" --post_content="$content" --porcelain
  fi
}

CAMPAIGNS_CONTENT='<h2>Nos campagnes solidaires</h2><p>Retrouvez ici les projets actuellement ouverts au soutien de notre communauté.</p>[give_form_grid columns="3" show_goal="true" show_excerpt="true"]'
DONATE_CONTENT='<h2>Choisissez l’action que vous souhaitez soutenir</h2><p>Chaque formulaire correspond à une campagne ou à un besoin spécifique. Sélectionnez une cause pour contribuer.</p>[give_form_grid columns="2" show_goal="true" show_excerpt="true"]'
IMPACT_CONTENT='<h2>Votre générosité en action</h2><p>Nous voulons rendre visible la dynamique créée autour de nos campagnes. Découvrez les soutiens de la communauté.</p><h3>Notre communauté de donateurs</h3>[give_donor_wall columns="3" anonymous="true"]'
DONOR_CONTENT='<h2>Votre espace personnel</h2><p>Consultez vos dons, vos reçus et les informations liées à votre profil.</p>[give_donor_dashboard]'
ABOUT_CONTENT='<h2>Agir ensemble, de manière simple et transparente</h2><p>Notre plateforme rassemble des campagnes de collecte et permet à chacun de participer selon ses moyens. Les dons sont gérés avec GiveWP, directement dans WordPress.</p><h3>Notre engagement</h3><p>Présenter clairement les initiatives, faciliter le don et permettre aux contributeurs de retrouver leur historique et leurs reçus.</p>'

campaigns_id="$(create_page_if_missing nos-campagnes 'Nos campagnes' "$CAMPAIGNS_CONTENT")"
donate_id="$(create_page_if_missing faire-un-don 'Faire un don' "$DONATE_CONTENT")"
impact_id="$(create_page_if_missing notre-impact 'Notre impact' "$IMPACT_CONTENT")"
donor_id="$(create_page_if_missing espace-donateur 'Espace donateur' "$DONOR_CONTENT")"
about_id="$(create_page_if_missing a-propos 'À propos' "$ABOUT_CONTENT")"

# Une page Accueil est créée uniquement si aucune page d'accueil statique n'est définie.
show_on_front="$(wp_exec option get show_on_front 2>/dev/null || echo posts)"
front_id="$(wp_exec option get page_on_front 2>/dev/null || echo 0)"
if [[ "$show_on_front" != "page" || -z "$front_id" || "$front_id" == "0" ]]; then
  home_id="$(create_page_if_missing accueil 'Accueil' '<p>Bienvenue sur notre plateforme solidaire.</p>')"
  wp_exec option update show_on_front page >/dev/null
  wp_exec option update page_on_front "$home_id" >/dev/null
else
  echo "[INFO] La page d'accueil existante est conservée (ID $front_id)."
fi

echo "[8/9] Menu principal..."
MENU_NAME='Navigation principale'
if ! wp_exec menu list --fields=name --format=csv 2>/dev/null | tail -n +2 | grep -Fxq "$MENU_NAME"; then
  wp_exec menu create "$MENU_NAME" >/dev/null
fi
item_count="$(wp_exec menu item list "$MENU_NAME" --format=count 2>/dev/null || echo 0)"
if [[ "${item_count:-0}" == "0" ]]; then
  current_front="$(wp_exec option get page_on_front 2>/dev/null || true)"
  [[ -n "$current_front" && "$current_front" != "0" ]] && wp_exec menu item add-post "$MENU_NAME" "$current_front" >/dev/null || true
  wp_exec menu item add-post "$MENU_NAME" "$campaigns_id" >/dev/null
  wp_exec menu item add-post "$MENU_NAME" "$impact_id" >/dev/null
  wp_exec menu item add-post "$MENU_NAME" "$about_id" >/dev/null
fi
wp_exec menu location assign "$MENU_NAME" primary >/dev/null || true

echo "[9/9] Vérifications finales..."
docker compose ps
printf '\nSite              : %s\n' "$WORDPRESS_PUBLIC_URL"
printf 'Campagnes         : %s/nos-campagnes/\n' "$WORDPRESS_PUBLIC_URL"
printf 'Faire un don      : %s/faire-un-don/\n' "$WORDPRESS_PUBLIC_URL"
printf 'Espace donateur   : %s/espace-donateur/\n' "$WORDPRESS_PUBLIC_URL"
printf 'Administration    : %s/wp-admin\n' "$WORDPRESS_PUBLIC_URL"
printf 'Plugins           : %s/wp-admin/plugins.php\n' "$WORDPRESS_PUBLIC_URL"
printf 'Utilisateur admin : %s\n' "$WORDPRESS_ADMIN_USER"
echo "Mot de passe       : WORDPRESS_ADMIN_PASSWORD dans infra/wordpress/.env"
