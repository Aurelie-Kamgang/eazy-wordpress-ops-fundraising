# Semaphore — configuration du projet

Le point essentiel : Semaphore tourne dans un conteneur. `ansible_connection: local` exécuterait donc les tâches dans ce conteneur, et non sur la VM WordPress.

## Configuration

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

2. Key Store : créer une clé SSH avec le login `ubuntu`. Ne pas ajouter de Sudo Credential.

3. Inventory : type **File**, chemin :

```text
inventory/semaphore.yml
```

4. Template Ansible :

- Repository : ce repo
- Playbook : `site.yml`
- Inventory : celui ci-dessus
- Sudo credential : None
- Working directory : vide

5. Premier test : tag `check`.

Le résultat doit montrer que l'utilisateur distant est `ubuntu`, que son HOME est `/home/ubuntu`, que Docker répond et que les deux conteneurs WordPress/MySQL sont démarrés.

6. Tags métier :

```text
backup_db
backup_files
backup_full
restore_db
restore_files
restore_full
update_plugins
```

Si les tags sont passés dans "Extra CLI arguments", utiliser par exemple :

```json
["--tags", "backup_db"]
```
