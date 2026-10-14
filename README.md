# EAZYTraining – WordPress Ops + GiveWP

Ce dépôt contient un environnement WordPress de préproduction orienté **collecte de dons avec GiveWP**, ainsi que les routines Ansible nécessaires pour exploiter le site : sauvegarde, restauration et mise à jour de plugins.

Le site public reste une application métier de collecte de fonds. **Ansible et Semaphore ne sont pas exposés dans le design du site** : ils restent des outils d'exploitation séparés.

## 1. Architecture

```text
Navigateur
   |
   v
VM WordPress :8004
   |
   +-- Docker : eazy-wp-wordpress
   |      +-- thème EAZYTraining Impact
   |      +-- GiveWP
   |
   +-- Docker : eazy-wp-db (MySQL)

Ansible / Semaphore
   |
   +-- backup_db
   +-- backup_files
   +-- backup_full
   +-- restore_db
   +-- restore_files
   +-- restore_full
   +-- update_plugins
```

## 2. Premier lancement sur la VM

```bash
unzip eazy-wordpress-ops-fundraising.zip
cd eazy-wordpress-ops-fundraising
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh wordpress
```

Au premier lancement, le script crée :

```text
infra/wordpress/.env
```

Édite-le :

```bash
nano infra/wordpress/.env
```

Configure au minimum :

```env
WORDPRESS_PUBLIC_URL=http://IP_PUBLIQUE_VM:8004
WORDPRESS_SITE_TITLE="EAZYTraining Impact"
MYSQL_PASSWORD=un_mot_de_passe
MYSQL_ROOT_PASSWORD=un_autre_mot_de_passe
WORDPRESS_ADMIN_PASSWORD=un_mot_de_passe_admin
```

Puis relance :

```bash
./bootstrap.sh wordpress
```

Le bootstrap :

1. construit et démarre WordPress/MySQL ;
2. attend que MySQL soit healthy ;
3. conserve la base WordPress existante si WordPress est déjà installé ;
4. synchronise et active le thème ;
5. installe le code GiveWP fourni uniquement si GiveWP n'est pas déjà installé ;
6. conserve les formulaires, dons et pages déjà présents en base ;
7. crée uniquement les pages métier absentes : **Nos campagnes**, **Faire un don**, **Notre impact**, **Espace donateur**, **À propos** ;
8. prépare la navigation.

> Important : le bootstrap ne supprime pas les volumes Docker et ne réinitialise pas la base.

## 3. Pages du site

- `/` : page d'accueil au design solidaire ;
- `/nos-campagnes/` : grille des formulaires/campagnes GiveWP ;
- `/faire-un-don/` : sélection des campagnes et formulaires de don ;
- `/notre-impact/` : communauté/donateurs ;
- `/espace-donateur/` : tableau de bord GiveWP du donateur ;
- `/wp-admin/` : administration WordPress ;
- `/wp-admin/plugins.php` : gestion des plugins.

## 4. Vérifier WordPress

```bash
./bootstrap.sh check
```

ou :

```bash
cd infra/wordpress
docker compose ps
docker logs --tail 50 eazy-wp-wordpress
docker logs --tail 50 eazy-wp-db
```

## 5. Tester Ansible avant Semaphore

Depuis la racine :

```bash
python3 -m pip install -r requirements.txt
ansible wordpress_servers -m ping
ansible-playbook site.yml --list-tags
```

### Backup DB

```bash
ansible-playbook site.yml --tags backup_db
```

### Backup fichiers WordPress

```bash
ansible-playbook site.yml --tags backup_files
```

### Backup complet

```bash
ansible-playbook site.yml --tags backup_full
```

Voir les backups :

```bash
./scripts/latest-backups.sh
```

## 6. Variables à modifier dans le repo

Le fichier principal est :

```text
inventory/group_vars/wordpress_servers.yml
```

### Mise à jour d'un plugin

```yaml
plugins_to_update:
  - name: "give"
    version: "latest"
```

Puis :

```bash
ansible-playbook site.yml --tags update_plugins
```

GitHub garde naturellement l'historique de la modification de la variable. Le playbook ne fait aucun `git commit` ni `git push`.

### Restauration DB

```yaml
restore_db_filename: "wordpress_db_YYYYMMDDTHHMMSS.sql"
restore_confirm: true
```

Puis :

```bash
ansible-playbook site.yml --tags restore_db
```

### Restauration fichiers

```yaml
restore_files_filename: "wordpress_files_YYYYMMDDTHHMMSS.tar.gz"
restore_confirm: true
```

Puis :

```bash
ansible-playbook site.yml --tags restore_files
```

Après une restauration, remets :

```yaml
restore_confirm: false
```

## 7. Semaphore

Ne passe à Semaphore qu'après avoir validé les playbooks manuellement.

```bash
./bootstrap.sh semaphore
```

Puis consulte `SEMAPHORE.md` pour créer le projet, le repository, l'inventaire et les Task Templates.

Les templates Semaphore utilisent les mêmes tags :

```text
backup_db
backup_files
backup_full
restore_db
restore_files
restore_full
update_plugins
```

## 8. Principe important

Le site WordPress représente l'application métier. Le repository contient les paramètres d'exploitation. Semaphore déclenche uniquement la routine choisie. Ainsi, la démonstration reste simple à expliquer :

```text
GitHub (code + variables) -> Semaphore (tag) -> Ansible -> WordPress
```

# Démonstration rapide des restaurations WordPress

## Restaurer les fichiers du site

### 1. Faire un backup

```bash
ansible-playbook site.yml --tags backup_files
```

### 2. Modifier visuellement le site

Ajouter une bannière rouge :

```bash
docker exec eazy-wp-wordpress sh -c \
'echo "<div style=\"background:red;color:white;padding:30px;text-align:center;font-size:30px;font-weight:bold;\">SITE MODIFIÉ AVANT RESTAURATION</div>" >> /var/www/html/wp-content/themes/eazytraining-preprod/header.php'
```

Rafraîchir le site avec `Ctrl + F5`.

### 3. Indiquer le backup à restaurer

Dans :

```text
inventory/group_vars/wordpress_servers.yml
```

mettre :

```yaml
restore_files_filename: "wordpress_files_XXXXXXXX.tar.gz"
restore_confirm: true
```

### 4. Restaurer

```bash
ansible-playbook site.yml --tags restore_files
```

Rafraîchir le site : la bannière rouge doit disparaître.

---

## Restaurer la base de données

### 1. Faire un backup

```bash
ansible-playbook site.yml --tags backup_db
```

### 2. Créer une donnée après le backup

```bash
docker exec eazy-wp-db sh -c \
'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "
CREATE TABLE demo_restore (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message VARCHAR(255)
);
INSERT INTO demo_restore (message)
VALUES (\"Créé après le backup\");
"'
```

Vérifier :

```bash
docker exec eazy-wp-db sh -c \
'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "
SELECT * FROM demo_restore;
"'
```

### 3. Indiquer le backup à restaurer

Dans :

```text
inventory/group_vars/wordpress_servers.yml
```

mettre :

```yaml
restore_db_filename: "wordpress_db_XXXXXXXX.sql"
restore_confirm: true
```

### 4. Restaurer

```bash
ansible-playbook site.yml --tags restore_db
```

### 5. Vérifier

```bash
docker exec eazy-wp-db sh -c \
'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "
SHOW TABLES LIKE '\''demo_restore'\'';
"'
```

La table `demo_restore` ne doit plus exister.

---

## Résumé

```text
Fichiers :
backup_files → modification visible → restore_files → site restauré

Base de données :
backup_db → création d'une table → restore_db → table supprimée
```
