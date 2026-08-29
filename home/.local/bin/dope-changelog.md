# Changelog — Script `dope` : Mappage d'utilisateur hôte

## Contexte

Le script `dope` lance opencode dans un conteneur persistant (Docker ou Podman). Le script original exécutait le conteneur en tant que **root**, ce qui faisait que tous les fichiers créés dans les volumes montés appartenaient à `root` sur la machine hôte (visibles comme `nobody:nobody`). Cela posait des problèmes de permissions sur les fichiers de projet, caches et configuration.

## Objectif

Garantir que les fichiers créés dans le conteneur appartiennent à l'utilisateur hôte actif, de manière transparente et automatique, sans intervention manuelle.

## Changements apportés

### 1. Détection automatique du mode de mappage utilisateur

Nouvelle fonction `detect_userns_mode()` qui sélectionne la meilleure stratégie selon le runtime détecté :

| Mode       | Runtime concerné       | Mécanisme                                         |
|------------|------------------------|---------------------------------------------------|
| `keep-id`  | Podman                | `--userns=keep-id` : root conteneur = user hôte    |
| `hostuser` | Docker (rootful)      | `--user $UID:$GID` + chown une seule fois          |
| `none`     | Docker (rootless)     | Pas de remapping (déjà géré par Docker rootless)  |

Détection automatique via `DEV_ID_USERNS=auto` (valeur par défaut). L'utilisateur peut forcer un mode avec la variable d'environnement `DEV_ID_USERNS`.

### 2. Correction des permissions conteneur (mode Docker rootful)

Nouvelle fonction `fix_container_perms()` exécutée après le démarrage du conteneur :

- S'applique uniquement en mode `hostuser` (Docker rootful)
- Fait un `chown -R $UID:$GID /root` à l'intérieur du conteneur (via `exec -u 0`)
- Skip automatique si les permissions sont déjà correctes (vérification via `stat`)
- Idempotent : ne s'exécute qu'une seule fois par conteneur

### 3. Adaptation des volumes en mode `hostuser`

En mode `hostuser`, les volumes nommés Docker seraient créés avec ownership `root`, donc inaccessibles à l'uid hôte. Le script substitue :

- `dope-data` (volume nommé) → bind mount `$HOME/.dope-cache/opencode-data`
- `dope-npm-cache` (volume nommé) → bind mount `$HOME/.dope-npm`

### 4. Compatibilité SELinux

Tous les bind mounts portent désormais le flag `:z` (relabeling SELinux) pour assurer le bon fonctionnement sur les systèmes avec SELinux actif (Fedora, RHEL, etc.).

### 5. Visibilité du mode actif

- `cmd_status` affiche désormais le mode user-namespace utilisé
- La création du conteneur affiche `User-ns: <mode>`
- L'aide (`help`) documente la variable `DEV_ID_USERNS`

## Résumé technique

| Avant                                   | Après                                                |
|-----------------------------------------|------------------------------------------------------|
| Conteneur toujours en root              | Conteneur mappé sur l'utilisateur hôte               |
| Fichiers = `nobody:nobody` sur l'hôte   | Fichiers = utilisateur hôte                          |
| Volumes nommés root-owned               | Bind mounts avec ownership correcte (mode hostuser)  |
| Pas de gestion SELinux                  | Flag `:z` sur tous les bind mounts                   |
| Pas de stratégie configurable           | `DEV_ID_USERNS` configurable (auto/keep-id/hostuser/none) |

## Variables d'environnement

| Variable          | Description                                      | Défaut |
|-------------------|--------------------------------------------------|--------|
| `DEV_ID_USERNS`   | Mode de mappage : `auto`, `keep-id`, `hostuser`, `none` | `auto` |

## Fichiers concernés

- `dope` — script modifié (232 → 294 lignes)
- `dope.backup` — version originale conservée comme sauvegarde
