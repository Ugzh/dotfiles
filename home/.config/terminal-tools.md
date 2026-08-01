# Outils modernes du terminal

Ce document décrit les outils ajoutés au terminal, leur intérêt, leur
configuration et les commandes les plus utiles au quotidien.

## Vue d'ensemble

| Outil | Rôle | Remplace ou complète |
|---|---|---|
| `delta` | Affichage moderne des différences Git | Le pager classique de `git diff` |
| `xh` | Test d'API HTTP lisible et rapide | Complète `curl` |
| `dust` | Analyse visuelle de l'espace disque | Simplifie `du` |
| `rg` / ripgrep | Recherche récursive très rapide | Remplace la plupart des usages de `grep -R` |
| `tldr` | Aide par exemples concrets | Complète `man` et `--help` |
| `yazi` | Gestionnaire de fichiers dans le terminal | Complète `cd`, `ls` et l'explorateur graphique |
| `fzf-tab` | Complétion Zsh interactive | Remplace le menu de complétion classique |
| `zellij` | Sessions, onglets et panneaux | Alternative moderne à tmux |
| `posting` | Client d'API HTTP interactif | Complète `xh` pour les scénarios visuels |
| `harlequin` | IDE SQL dans le terminal | Complète les clients SQL en ligne de commande |
| `lnav` | Lecture et analyse de journaux | Remplace `less` pour les logs structurés |
| `fx` | Exploration et transformation de JSON | Complète `jq` avec une interface interactive |
| `pitchfork` | Supervision des processus de développement | Remplace plusieurs terminaux lancés à la main |
| `fnox` | Gestion des secrets par projet | Évite les secrets en clair dans les commandes |
| `mise` | Versions d'outils, environnement et tâches | Regroupe `nvm`, `pyenv`, scripts et variables |

Les commandes qui le permettent disposent de la complétion Zsh. Après une
modification de leur configuration, un nouveau shell peut être chargé avec :

```bash
exec zsh
```

## Delta

Documentation officielle : [dandavison.github.io/delta](https://dandavison.github.io/delta/)

### Utilité

Delta améliore automatiquement les sorties Git contenant un diff : coloration
syntaxique, numéros de ligne, distinction claire des ajouts et suppressions,
et navigation entre les fichiers modifiés.

Il est configuré comme pager Git global. Il n'est donc pas nécessaire de
lancer `delta` directement.

### Utilisation courante

```bash
# Modifications non indexées
git diff

# Modifications ajoutées à l'index
git diff --staged

# Contenu du dernier commit
git show

# Historique avec les modifications
git log -p

# Comparaison entre deux branches
git diff main...feature/ma-branche
```

Dans le pager :

| Touche | Action |
|---|---|
| `n` | Aller au prochain fichier ou bloc de modifications |
| `N` | Revenir au précédent |
| `/texte` | Rechercher du texte |
| `q` | Fermer le pager |

### Configuration active

- thème syntaxique Dracula, adapté au thème sombre ;
- couleurs Obsidian Rose pour les ajouts et suppressions ;
- numéros de ligne ;
- liens de fichiers cliquables lorsque le terminal les prend en charge ;
- affichage unifié, sans mode côte à côte ;
- conflits Git au format `zdiff3`, qui montre également la base commune.

Configuration : `~/.gitconfig`

## xh

Documentation officielle : [github.com/ducaale/xh](https://github.com/ducaale/xh)

### Utilité

`xh` est un client HTTP inspiré de HTTPie. Sa syntaxe est plus courte et plus
lisible que celle de `curl` pour tester une API, tout en conservant une sortie
JSON colorée.

Une URL commençant par `:` désigne localhost :

```bash
xh :3000/users
# Équivaut à http://localhost:3000/users
```

### Requêtes simples

```bash
# GET implicite
xh :3000/users

# GET explicite
xh GET :3000/users

# POST JSON
xh POST :3000/users name=Ugo email=ugo@example.com

# Valeurs JSON typées : nombre, booléen, tableau ou objet
xh POST :3000/users name=Ugo age:=30 active:=true

# PUT et DELETE
xh PUT :3000/users/42 name=NouveauNom
xh DELETE :3000/users/42
```

### Paramètres, en-têtes et authentification

La ponctuation après un nom indique à `xh` comment traiter la valeur :

| Syntaxe | Signification | Exemple |
|---|---|---|
| `clé=valeur` | Champ JSON sous forme de texte | `name=Ugo` |
| `clé:=valeur` | Valeur JSON typée | `active:=true` |
| `clé==valeur` | Paramètre de query string | `page==2` |
| `En-Tête:valeur` | En-tête HTTP | `Accept:application/json` |

```bash
# Query string : /users?page=2&limit=20
xh GET :3000/users page==2 limit==20

# En-tête personnalisé
xh GET :3000/users X-Request-ID:test-123

# Bearer token
xh GET :3000/me -A bearer -a "$API_TOKEN"

# Authentification Basic
xh GET example.com/private -a utilisateur:mot-de-passe
```

Évite d'écrire les secrets directement dans l'historique. Utilise de
préférence une variable d'environnement ou un fichier protégé.

### Réponses et diagnostic

```bash
# Corps uniquement
xh --body GET :3000/users

# En-têtes uniquement
xh --headers GET :3000/users

# Requête et réponse complètes
xh --verbose GET :3000/users

# Suivre les redirections
xh --follow example.com

# Construire la requête sans l'envoyer
xh --offline POST :3000/users name=Ugo

# Traduire la commande en curl
xh --curl POST :3000/users name=Ugo
```

L'alias `xhs` force HTTPS :

```bash
xhs GET example.com/api/health
```

Configuration de l'alias et de la complétion : `~/.zshrc`

## Dust

Documentation officielle : [github.com/bootandy/dust](https://github.com/bootandy/dust)

### Utilité

`dust` analyse l'espace disque et montre directement les répertoires et
fichiers les plus volumineux sous forme d'arbre. Il est plus rapide à lire que
la combinaison classique `du | sort`.

### Utilisation courante

```bash
# Répertoire courant
dust

# Un répertoire précis
dust ~/Dev

# Limiter la profondeur de l'arbre
dust -d 2 ~/Dev

# Afficher seulement les 20 plus grosses entrées
dust -n 20 ~

# Ne pas traverser d'autres systèmes de fichiers
dust -x /

# Ignorer node_modules
dust -X node_modules ~/Dev

# Chercher uniquement les plus gros fichiers
dust --only-file -n 20 ~/Downloads
```

Autres options utiles :

| Option | Action |
|---|---|
| `-d N` | Limiter l'analyse à `N` niveaux |
| `-n N` | Limiter le nombre d'éléments affichés |
| `-X chemin` | Ignorer un chemin |
| `-i` | Ignorer les fichiers cachés |
| `-x` | Rester sur le système de fichiers courant |
| `-F` / `--only-file` | Afficher uniquement les fichiers |
| `-D` / `--only-dir` | Afficher uniquement les dossiers |
| `--print-errors` | Montrer les chemins impossibles à lire |

La configuration actuelle place les plus gros éléments en haut de l'écran.

Configuration : `~/.config/dust/config.toml`

## ripgrep / rg

Documentation officielle : [github.com/BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep)

### Utilité

ripgrep recherche du texte récursivement dans un projet. Sa commande est
`rg`. Il respecte automatiquement `.gitignore` et ignore les fichiers binaires
ainsi que les dossiers cachés, ce qui le rend particulièrement adapté au code.

```bash
# Rechercher dans le dossier courant
rg "TODO"

# Rechercher dans un dossier précis avec les numéros de ligne
rg -n "AuthenticationService" src/

# Recherche insensible à la casse
rg -i "authorization"

# Limiter ou exclure des types de fichiers
rg -t ts "deprecated"
rg -g '*.kt' "suspend fun"
rg -g '!node_modules/**' "localhost"

# Afficher deux lignes de contexte avant et après
rg -C 2 "panic"

# Lister uniquement les fichiers contenant le motif
rg -l "DATABASE_URL"

# Inclure les fichiers cachés, tout en respectant .gitignore
rg --hidden "ma-recherche"
```

Options utiles :

| Option | Action |
|---|---|
| `-i` | Ignorer la casse |
| `-F` | Traiter le motif comme du texte, sans expression régulière |
| `-w` | Chercher un mot entier |
| `-l` | Afficher seulement les noms des fichiers |
| `-g GLOB` | Inclure ou exclure des chemins |
| `-t TYPE` | Limiter à un type, par exemple `ts`, `py` ou `rust` |
| `-C N` | Afficher `N` lignes de contexte |
| `--hidden` | Inclure les fichiers cachés |
| `-uuu` | Désactiver tous les filtres automatiques |

Évite `-uuu` sauf nécessité : cela inclut aussi `.git`, les fichiers ignorés
et les fichiers binaires. ripgrep est installé par Fedora dans `/usr/bin/rg`.

## Tealdeer / tldr

Documentation officielle : [tealdeer-rs.github.io](https://tealdeer-rs.github.io/tealdeer/)

### Utilité

Tealdeer fournit la commande `tldr`. Elle affiche une fiche courte composée
d'exemples pratiques, contrairement à `man`, qui documente toutes les options.

```bash
tldr git
tldr podman
tldr fd
tldr systemctl
tldr xh
```

### Recherche et maintenance

```bash
# Chercher une commande parmi les pages disponibles
tldr --list | fzf

# Mettre manuellement les pages à jour
tldr --update

# Afficher les chemins utilisés par Tealdeer
tldr --show-paths

# Afficher une page pour une plateforme précise
tldr --platform linux tar
```

Le cache des pages est déjà initialisé. La configuration vérifie
automatiquement les mises à jour une fois par semaine et utilise un pager pour
les pages longues.

Configuration : `~/.config/tealdeer/config.toml`

## Yazi

Documentation officielle : [yazi-rs.github.io](https://yazi-rs.github.io/docs/quick-start/)

### Utilité

Yazi est un gestionnaire de fichiers rapide qui s'ouvre directement dans le
terminal. Il affiche les dossiers, les fichiers et un aperçu du contenu dans
trois colonnes. Sa navigation reprend les touches de Vim.

### Démarrage

```bash
# Ouvrir le dossier courant
y

# Ouvrir un dossier précis
y ~/Dev

# Lancer sans changer le dossier du shell à la fermeture
yazi
```

La fonction `y` est recommandée : en quittant avec `q`, le shell se place dans
le dernier dossier visité. Quitter avec `Q` conserve le dossier initial.

### Navigation

| Touche | Action |
|---|---|
| `j` / `↓` | Descendre |
| `k` / `↑` | Monter |
| `l` / `→` / `Entrée` | Entrer dans un dossier ou ouvrir un fichier |
| `h` / `←` | Revenir au dossier parent |
| `g g` / `G` | Aller au début / à la fin |
| `z` | Choisir un chemin avec `fzf` |
| `Z` | Choisir un dossier avec `zoxide` |
| `F1` ou `~` | Afficher toute l'aide |
| `q` | Quitter et conserver le dernier dossier avec la fonction `y` |
| `Q` | Quitter sans changer le dossier du shell |

### Fichiers et recherche

| Touche | Action |
|---|---|
| `Espace` | Sélectionner ou désélectionner |
| `y` / `x` / `p` | Copier / couper / coller |
| `d` / `D` | Mettre à la corbeille / supprimer définitivement |
| `a` | Créer un fichier, ou un dossier si le nom finit par `/` |
| `r` | Renommer |
| `.` | Afficher ou masquer les fichiers cachés |
| `f` | Filtrer la liste courante |
| `s` | Rechercher des noms avec `fd` |
| `S` | Rechercher dans le contenu avec `ripgrep` |
| `c c` / `c d` / `c f` | Copier le chemin / dossier / nom du fichier |

`ya` est le compagnon en ligne de commande de Yazi. Il sert surtout à gérer
les paquets et extensions de Yazi ; `ya --help` affiche les commandes
disponibles.

Les binaires sont installés dans `~/.local/bin/yazi` et `~/.local/bin/ya`.
Leurs complétions Zsh se trouvent dans
`~/.local/share/zsh/site-functions/_yazi` et `_ya`. La fonction `y` est dans
`~/.zshrc`. Le thème Obsidian Rose se trouve dans
`~/.config/yazi/theme.toml`. L'opener `edit` et les variables `EDITOR` et
`VISUAL` utilisent Neovim : ouvrir un fichier texte avec `Entrée` suspend Yazi,
lance Neovim, puis restaure Yazi à la fermeture de l'éditeur.

## fzf-tab

Documentation officielle : [github.com/Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab)

### Utilité

`fzf-tab` remplace le menu affiché par la touche `Tab` de Zsh par une liste
filtrable avec `fzf`. Il utilise les complétions natives : commandes, options,
branches Git, processus, chemins et variables continuent donc de fonctionner.

```bash
# Écrire une partie du nom, puis appuyer sur Tab
cd ~/D<Tab>
git checkout fea<Tab>
kill <Tab>
```

Dans la fenêtre de sélection :

| Touche | Action |
|---|---|
| saisie | Filtrer les propositions |
| `Tab` / `Shift+Tab` | Descendre / monter |
| `Entrée` | Accepter la proposition |
| `Ctrl+Espace` | Sélectionner plusieurs éléments |
| `<` / `>` | Changer de groupe de résultats |
| `Esc` | Fermer sans compléter |

La complétion de `cd` affiche un aperçu avec `eza`. Dans tmux, la sélection
s'ouvre dans une popup ; ailleurs, elle reste intégrée à la ligne courante.
Le plugin est chargé après `compinit` et avant les plugins ZLE pour éviter les
conflits avec autosuggestions, la coloration syntaxique et Atuin.

Configuration : `~/.zshrc`  
Installation : `~/.local/share/zsh/plugins/fzf-tab/`

## Zellij

Documentation officielle : [zellij.dev/documentation](https://zellij.dev/documentation/)

### Utilité

Zellij conserve des sessions de terminal et permet de créer des panneaux et
des onglets. Il est installé comme alternative à tmux et ne démarre pas
automatiquement.

```bash
# Rouvrir automatiquement la session la plus récente
zellij

# Même comportement avec le raccourci
zj

# Nouvelle session nommée
zellij --session backend

# Lister puis rejoindre les sessions
zellij list-sessions
zellij attach backend

# Forcer une nouvelle session même si d'anciennes existent
zellij --session nouveau-projet
```

Sans argument, la fonction Zsh `zellij` sélectionne la première entrée de
`zellij list-sessions --reverse` : elle rejoint une session encore active ou
ressuscite la dernière session arrêtée. Lorsqu'aucune sauvegarde n'existe,
Zellij crée normalement une nouvelle session. Les sous-commandes et options
explicites (`zellij list-sessions`, `zellij attach backend`, etc.) ne sont pas
modifiées.

Lors d'une résurrection, Zellij restaure les onglets, panneaux et répertoires.
Par sécurité, une commande précédemment active demande `Entrée` avant d'être
relancée ; le wrapper n'utilise volontairement pas `--force-run-commands`.

Les commandes commencent généralement par `Ctrl+P` pour les panneaux,
`Ctrl+T` pour les onglets et `Ctrl+S` pour le défilement. La barre compacte
affiche les raccourcis disponibles. `Ctrl+O`, puis `d`, détache la session.

### Onglets

Des raccourcis directs sont ajoutés pour les actions fréquentes :

| Action | Raccourci direct | Raccourci Zellij natif |
|---|---|---|
| Nouvel onglet | `Alt+T` | `Ctrl+T`, puis `n` |
| Renommer | `Alt+R`, saisir le nom, `Entrée` | `Ctrl+T`, puis `r` |
| Onglet précédent / suivant | `Alt+,` / `Alt+.` | `Ctrl+T`, puis `h` / `l` |
| Aller à l'onglet 1 à 9 | `Alt+1`…`Alt+9` | `Ctrl+T`, puis `1`…`9` |
| Fermer l'onglet | — | `Ctrl+T`, puis `x` |
| Rechercher un onglet par son nom | `Alt+S` | — |
| Afficher l'aide des raccourcis | `Alt+B` | — |

Les raccourcis directs fonctionnent en mode `NORMAL`. Les raccourcis natifs
restent disponibles et la barre inférieure rappelle les touches du mode actif.

### Interface et plugins

Les cadres de panneaux sont désactivés : plus de bord supérieur, inférieur ou
latéral autour d'un panneau unique. Seule une barre `zjstatus` d'une ligne
reste visible en bas. Elle reprend la palette Obsidian Rose et affiche le mode,
la session, les onglets, la branche Git et l'heure.

La sélection [Awesome Zellij](https://github.com/zellij-org/awesome-zellij)
contient beaucoup de plugins communautaires. Ceux installés ici sont :

| Plugin | Intérêt | Utilisation |
|---|---|---|
| [zjstatus](https://github.com/dj95/zjstatus) | Barre d'état totalement personnalisable | Chargé automatiquement par le layout |
| [room](https://github.com/rvcas/room) | Recherche et changement d'onglet rapide | `Alt+S`, taper, puis `Entrée` |
| [zellij-forgot](https://github.com/karimould/zellij-forgot) | Popup listant les raccourcis actifs | `Alt+B` |
| [neolij](https://github.com/y2w8/neolij.nvim) | Navigation transparente entre Neovim et Zellij | `Ctrl+H/J/K/L` dans Neovim |

Dans Room, `Tab` ou les flèches changent la sélection, un chiffre saute
directement à l'onglet correspondant, et `Échap` ferme la fenêtre. Au premier
lancement de chaque plugin Zellij, sélectionner sa fenêtre et accepter les
permissions avec `y`.

Neolij ajoute aussi ces actions depuis Neovim :

| Action | Raccourci Neovim |
|---|---|
| Nouvel onglet Zellij | `<leader>zt` |
| Renommer l'onglet | `<leader>zr` |
| Déplacer l'onglet à gauche / droite | `<leader>z,` / `<leader>z.` |

La configuration active utilise Zsh, le thème et le layout `obsidian-rose`.
Zellij possède sa propre complétion Zsh.

Configurations : `~/.config/zellij/config.kdl`,
`~/.config/zellij/layouts/obsidian-rose.kdl` et
`~/.config/nvim/lua/ugzher/plugins/neolij.lua`

## Posting

Documentation officielle : [posting.sh/guide](https://posting.sh/guide/)

### Utilité

Posting est un client d'API HTTP interactif. Contrairement à `xh`, il conserve
des collections de requêtes et affiche côte à côte URL, en-têtes, corps et
réponse.

```bash
# Collection globale
posting

# Collection versionnable dans un projet
mkdir -p api-requests
posting --collection api-requests

# Localiser sa configuration
posting locate config
```

Raccourcis essentiels :

| Touche | Action |
|---|---|
| `Ctrl+T` | Choisir la méthode HTTP |
| `Tab` / `Shift+Tab` | Changer de zone |
| `Ctrl+J` ou `Alt+Entrée` | Envoyer la requête |
| `Ctrl+S` | Enregistrer la requête |
| `Ctrl+P` | Ouvrir la palette de commandes |
| `F1` | Afficher l'aide |

Les requêtes enregistrées sont de simples fichiers `.posting.yaml`. La
configuration utilise l'interface compacte et le thème Dracula.

Configuration : `~/.config/posting/config.yaml`

## Harlequin

Documentation officielle : [harlequin.sh/docs](https://harlequin.sh/docs/getting-started/)

### Utilité

Harlequin est un IDE SQL interactif. Il fournit un éditeur, un catalogue des
tables, l'autocomplétion, l'historique et une grille de résultats exportable.
DuckDB et SQLite sont disponibles immédiatement.

```bash
# DuckDB en mémoire
harlequin

# Base DuckDB existante
harlequin data.duckdb

# Base SQLite
harlequin -a sqlite app.db

# Afficher aussi les fichiers d'un projet
harlequin --show-files . data.duckdb
```

| Touche | Action |
|---|---|
| `Ctrl+Entrée` ou `Ctrl+J` | Exécuter la requête |
| `F2` / `F5` / `F6` | Éditeur / résultats / catalogue |
| `F4` | Formater le SQL |
| `Ctrl+E` | Exporter les résultats |
| `Ctrl+Q` | Quitter |
| `F1` | Afficher l'aide |

Le profil par défaut utilise DuckDB, limite l'affichage à 100 000 lignes et
applique le thème Dracula. Un adaptateur PostgreSQL pourra être ajouté avec
`uv tool install --force 'harlequin[postgres]'` si nécessaire.

Configuration : `~/.harlequin.toml`

## lnav

Documentation officielle : [docs.lnav.org](https://docs.lnav.org/en/stable/)

### Utilité

`lnav` reconnaît automatiquement de nombreux formats de journaux, fusionne
plusieurs fichiers selon leur horodatage, colore les niveaux et permet de les
interroger en SQL.

```bash
# Un fichier ou tous les logs d'un dossier
lnav app.log
lnav logs/

# Plusieurs fichiers, y compris compressés
lnav logs/*.log logs/archive.log.gz

# Suivre les logs d'un conteneur
podman logs -f mon-conteneur | lnav

# Lire directement la sortie du journal système
journalctl -f -u mon-service | lnav
```

| Touche | Action |
|---|---|
| `e` / `E` | Erreur suivante / précédente |
| `w` / `W` | Avertissement suivant / précédent |
| `/texte` | Rechercher |
| `i` | Afficher ou masquer l'histogramme |
| `:` | Saisir une commande lnav |
| `;` | Interroger les logs en SQL |
| `q` | Quitter |

Exemple dans l'invite SQL ouverte avec `;` :

```sql
SELECT log_time, log_level, log_body
FROM all_logs
WHERE log_level = 'error';
```

`lnav` est installé localement depuis le paquet Fedora.

## fx

Documentation officielle : [fx.wtf](https://fx.wtf/getting-started)

### Utilité

`fx` affiche et explore du JSON dans une interface interactive. Il peut aussi
transformer les données avec des expressions JavaScript et accepte les flux
JSON, JSONL, YAML et TOML.

```bash
# Explorer un fichier ou une réponse HTTP
fx response.json
xh GET :3000/users | fx

# Extraire une propriété
echo '{"user":{"name":"Ugo"}}' | fx .user.name

# Transformer avec JavaScript
fx users.json '.users.map(user => user.email)'

# Regrouper un flux JSONL avant de le traiter
fx --slurp events.jsonl '.map(event => event.type)'
```

Dans l'interface :

| Touche | Action |
|---|---|
| `j` / `k` ou flèches | Naviguer |
| `l` / `h` | Déplier / replier |
| `/` | Rechercher avec une expression régulière |
| `n` / `N` | Résultat suivant / précédent |
| `@` | Rechercher un chemin avec `fzf` |
| `.` | Saisir directement un chemin JSON |
| `p` / `P` | Prévisualiser / imprimer la valeur courante |
| `?` | Afficher tous les raccourcis |
| `q` | Quitter |

Le rendu interactif est envoyé sur stderr. Il est donc possible de naviguer,
de choisir une valeur avec `P` et de rediriger uniquement cette valeur :

```bash
fx response.json > selection.json
```

## Pitchfork

Documentation officielle : [pitchfork.jdx.dev](https://pitchfork.jdx.dev/)  
Guide du shell hook : [démarrage et arrêt automatiques](https://pitchfork.jdx.dev/guides/shell-hook.html)

### Utilité

Pitchfork lance, surveille et redémarre les processus nécessaires à un projet :
serveur HTTP, base de données, worker ou watcher. Il centralise leurs états et
leurs logs dans une interface TUI.

```bash
# Lancer ponctuellement un processus supervisé
pitchfork run web -- npm run dev

# Voir les processus et suivre leurs logs
pitchfork list
pitchfork logs web --tail
pitchfork tui

# Arrêter ou relancer
pitchfork stop web
pitchfork restart web
```

Un projet durable se décrit dans `pitchfork.toml` :

```toml
[daemons.api]
run = "npm run start:dev"
auto = ["start", "stop"]

[daemons.frontend]
run = "npm run dev"
auto = ["start", "stop"]
```

Le hook Zsh est déjà actif avec `eval "$(pitchfork activate zsh)"`. Lorsque le
shell entre dans un projet contenant cette configuration, les daemons marqués
`start` démarrent ; ils s'arrêtent après la sortie du projet si `stop` est
également présent.

## fnox

Documentation officielle : [fnox.jdx.dev](https://fnox.jdx.dev/guide/what-is-fnox.html)

### Utilité

fnox fournit une interface commune pour les secrets chiffrés dans Git, les
gestionnaires de mots de passe et les services cloud. Le projet référence ses
secrets dans `fnox.toml`, puis fnox les injecte seulement dans le processus qui
en a besoin.

```bash
# Initialiser un projet
fnox init

# Saisir la valeur sans l'inscrire dans l'historique
fnox set DATABASE_URL

# Vérifier les secrets requis et les lister sans afficher leurs valeurs
fnox check
fnox list

# Exécuter une commande avec les secrets dans son environnement
fnox exec -- npm run start:dev

# Interface interactive
fnox tui
```

Évite `fnox set CLE "secret"` : la valeur apparaîtrait dans l'historique du
shell. Préfère la saisie interactive ou un fournisseur distant. fnox prend en
charge différents profils, par exemple `fnox --profile staging exec -- task`.

L'intégration Zsh optionnelle charge et décharge automatiquement les secrets
en changeant de dossier :

```bash
eval "$(fnox activate zsh)"
```

## mise

Documentation officielle : [mise.jdx.dev](https://mise.jdx.dev/)

### Utilité

mise installe les versions d'outils attendues par chaque projet, charge les
variables d'environnement et exécute des tâches reproductibles. Sa
configuration locale est généralement un fichier `mise.toml` versionné.

```bash
# Installer et fixer les versions du projet courant
mise use node@24 pnpm@10 java@21

# Voir ce qui est actif et installer ce qui est déjà déclaré
mise ls
mise install

# Exécuter ponctuellement une version sans modifier le projet
mise exec node@24 -- node --version

# Lancer les tâches du projet
mise tasks
mise run test

# Diagnostic de l'intégration
mise doctor
```

Exemple de `mise.toml` :

```toml
[tools]
node = "24"
pnpm = "10"

[env]
NODE_ENV = "development"

[tasks.test]
run = "npm test"
```

Le hook `mise activate zsh` est actif : les versions et variables changent
automatiquement lorsque le shell entre dans un projet. Avant d'autoriser un
fichier récupéré depuis un dépôt, lis-le puis utilise `mise trust` ; les tâches
et hooks d'un `mise.toml` peuvent exécuter des commandes.

## Vérification et dépannage

Afficher les versions installées :

```bash
delta --version
xh --version
dust --version
rg --version
tldr --version
yazi --version
ya --version
zellij --version
posting --help
harlequin --version
lnav -V
fx --version
pitchfork --version
fnox --version
mise --version
```

Si une commande ou une complétion n'est pas reconnue :

```bash
exec zsh
```

Les binaires sont installés dans les emplacements utilisateur suivants :

- `delta`, `dust`, `tldr`, `yazi`, `ya`, `zellij` et `lnav` :
  `~/.local/bin/` ;
- `xh` : `~/.cargo/bin/` ;
- `posting` et `harlequin` : environnements isolés gérés par `uv`, avec leurs
  lanceurs dans `~/.local/bin/` ;
- `fx` : `~/.local/bin/fx` ;
- `pitchfork` et `fnox` : installations gérées par mise dans
  `~/.local/share/mise/installs/` ;
- `mise` : `~/.local/bin/mise` ;
- `rg` : `/usr/bin/rg`, fourni par le paquet Fedora `ripgrep` ;
- complétions Zsh : `~/.local/share/zsh/site-functions/`.

Ces deux dossiers de binaires sont ajoutés au `PATH` par la configuration Zsh
et Rust existante.
