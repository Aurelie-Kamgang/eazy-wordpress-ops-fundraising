# EAZYTraining WordPress Ops — CLI + Semaphore

Ce dépôt pilote un WordPress Dockerisé déjà installé sur une VM. Les mêmes rôles et tags Ansible sont utilisés en ligne de commande et dans Semaphore.

## 1. Architecture

```text
CLI sur la VM                         Semaphore (Docker)
      |                                     |
      | inventory/local.yml                 | inventory/semaphore.yml + clé SSH
      v                                     v
                  VM WordPress (ubuntu)
                         |
                  Docker WordPress/MySQL
                         |
              ~/wordpress-backups
```

**Important :** `localhost` dans un conteneur Semaphore désigne le conteneur Semaphore, pas la VM WordPress. C'est pourquoi Semaphore doit utiliser `inventory/semaphore.yml` en SSH.

## 2. Préparer WordPress

Si le WordPress n'est pas encore démarré :

```bash
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh wordpress
```

Vérifier :

```bash
./bootstrap.sh check
```

## 3. Tester Ansible directement sur la VM

```bash
./scripts/test-cli.sh
```

Ou manuellement :

```bash
ansible-playbook -i inventory/local.yml site.yml --tags check
ansible-playbook -i inventory/local.yml site.yml --tags backup_db
ansible-playbook -i inventory/local.yml site.yml --tags backup_files
ansible-playbook -i inventory/local.yml site.yml --tags backup_full
```

Les backups sont créés dans le HOME de l'utilisateur Ansible :

```bash
ls -lh ~/wordpress-backups/database/
ls -lh ~/wordpress-backups/files/
```

## 4. Variables à modifier dans GitHub

Fichier :

```text
inventory/group_vars/wordpress_servers.yml
```

### Plugin

```yaml
plugins_to_update:
  - name: "give"
    version: "latest"
```

Puis lancer le tag :

```text
update_plugins
```

### Restore DB

```yaml
restore_db_filename: "wordpress_db_XXXXXXXX.sql"
restore_confirm: true
```

Tag : `restore_db`

### Restore fichiers

```yaml
restore_files_filename: "wordpress_files_XXXXXXXX.tar.gz"
restore_confirm: true
```

Tag : `restore_files`

Après restauration, remettre :

```yaml
restore_confirm: false
```

## 5. Démarrer Semaphore

```bash
./bootstrap.sh semaphore
```

Le compose Semaphore ajoute `host.docker.internal` vers la VM hôte afin que le conteneur puisse joindre SSH sur la VM.

## 6. Configuration Semaphore obligatoire

### Key Store
Créer une clé SSH avec :

- type : **SSH Key**
- login : `ubuntu`
- clé privée : celle autorisée dans `/home/ubuntu/.ssh/authorized_keys` sur la VM WordPress

Ne pas configurer de clé sudo.

### Inventory
Créer un Inventory de type **File** :

```text
inventory/semaphore.yml
```

Associer la clé SSH `ubuntu` créée ci-dessus.

### Task Template

- Application : **Ansible Playbook**
- Repository : ce dépôt GitHub
- Playbook : `site.yml`
- Inventory : l'inventaire Semaphore précédent
- Working directory : vide (racine du repo)
- Sudo credential : **None**

Pour diagnostiquer d'abord, exécuter le tag :

```text
check
```

Puis créer/utiliser les tags :

```text
backup_db
backup_files
backup_full
restore_db
restore_files
restore_full
update_plugins
```

Dans Semaphore, les arguments CLI supplémentaires doivent être fournis au format JSON si tu les renseignes manuellement, par exemple :

```json
["--tags", "backup_db"]
```

## 7. Test attendu avant les vraies opérations

Le tag `check` doit afficher :

- utilisateur distant `ubuntu` ;
- HOME distant `/home/ubuntu` ;
- Docker disponible ;
- `eazy-wp-wordpress` démarré ;
- `eazy-wp-db` démarré ;
- écriture possible dans `/home/ubuntu/wordpress-backups`.

Si le tag `check` montre un HOME ou un utilisateur appartenant au conteneur Semaphore, l'inventaire Semaphore n'est pas le bon.

## 8. Démonstration rapide restore

### Fichiers

```bash
ansible-playbook -i inventory/local.yml site.yml --tags backup_files
```

Ajouter une bannière :

```bash
docker exec eazy-wp-wordpress sh -c \
'echo "<div style=\"background:red;color:white;padding:30px;text-align:center;font-size:30px;font-weight:bold;\">SITE MODIFIÉ AVANT RESTAURATION</div>" >> /var/www/html/wp-content/themes/eazytraining-preprod/header.php'
```

Configurer `restore_files_filename`, mettre `restore_confirm: true`, puis lancer `restore_files`. La bannière doit disparaître.

### DB

Faire `backup_db`, créer une table de test après le backup, configurer `restore_db_filename`, puis lancer `restore_db`. La table créée après le backup doit disparaître.
