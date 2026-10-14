# Configuration Ansible Semaphore

Cette partie se fait **après** avoir validé les playbooks en CLI.

## 1. Démarrer Semaphore

```bash
./bootstrap.sh semaphore
```

Au premier lancement, si `infra/semaphore/.env` n'existe pas, le script le crée et te demande de modifier le mot de passe. Relance ensuite la commande.

Ouvre :

```text
http://IP_PUBLIQUE_VM:3000
```

Le port 3000 doit être autorisé uniquement depuis ton IP/réseau d'administration.

## 2. Créer le projet Semaphore

Dans Semaphore :

1. **New Project** -> `EAZYTraining WordPress Ops`
2. **Key Store** -> ajoute la clé SSH privée permettant de joindre la VM WordPress.
3. **Repositories** -> ajoute l'URL GitHub du repo.
4. **Inventory** -> crée un inventory avec le groupe `wordpress_servers`.

Exemple :

```yaml
all:
  children:
    wordpress_servers:
      hosts:
        wordpress_vm:
          ansible_host: 172.31.36.255
          ansible_user: ubuntu
```

Utilise de préférence l'IP privée si Semaphore est dans le même VPC/réseau.

## 3. Créer les Task Templates

Tous utilisent :

```text
Playbook: site.yml
```

Crée un template par opération :

| Template | Tag |
|---|---|
| Backup DB | `backup_db` |
| Backup Site | `backup_files` |
| Backup complet | `backup_full` |
| Restore DB | `restore_db` |
| Restore Site | `restore_files` |
| Restore complet | `restore_full` |
| Update plugins | `update_plugins` |

Dans le champ **CLI Args / Tags** de Semaphore, configure le tag correspondant selon l'interface de ta version.

## 4. Variables versionnées dans GitHub

Le fichier à modifier est :

```text
inventory/group_vars/wordpress_servers.yml
```

Exemple plugin :

```yaml
plugins_to_update:
  - name: "give"
    version: "latest"
```

Exemple restauration :

```yaml
restore_db_filename: "wordpress_db_20261014T021500.sql"
restore_files_filename: "wordpress_files_20261014T021500.tar.gz"
restore_confirm: true
```

Une modification faite dans GitHub est naturellement enregistrée dans l'historique GitHub. Semaphore récupère ensuite le repo et exécute le playbook avec ces valeurs. **Ansible n'exécute aucun `git commit` ni `git push`.**

Après une restauration, remets :

```yaml
restore_confirm: false
```
