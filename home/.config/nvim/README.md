# Configuration Neovim

Configuration basée sur Neovim 0.12, Lazy, Snacks, Blink, Mason, le LSP natif,
Treesitter et Conform. Elle est principalement orientée TypeScript et
Kotlin/Gradle, avec une prise en charge de Lua, Angular, HTML/CSS, Python, Go,
Rust, C/C++, JSON, YAML et Markdown.

## Repères

La touche leader est `Espace`. Attendre environ 350 ms après l'avoir pressée
affiche les raccourcis disponibles avec Which-key.

Dans les tableaux ci-dessous, `<leader>` désigne donc `Espace`, `<C-x>` désigne
`Ctrl+x`, `<S-x>` désigne `Maj+x` et `<M-x>` désigne `Alt+x`.

## Recherche et navigation

| Raccourci | Action |
| --- | --- |
| `<leader><space>` | Recherche intelligente |
| `<leader>ff` | Rechercher un fichier |
| `<leader>fr` | Ouvrir un fichier récent |
| `<leader>fs` | Rechercher du texte dans le projet |
| `<leader>fc` | Rechercher le mot sous le curseur ou la sélection |
| `<leader>fb` | Rechercher parmi les buffers |
| `<leader>fh` | Rechercher dans l'aide |
| `<leader>fk` | Rechercher un raccourci |
| `<leader>fd` | Rechercher dans tous les diagnostics |
| `<leader>ef` | Ouvrir ou fermer l'explorateur de fichiers |
| `<leader>fp` | Copier le chemin du fichier courant |

## Buffers, fenêtres et onglets

| Raccourci | Action |
| --- | --- |
| `<S-h>` / `<S-l>` | Buffer précédent / suivant |
| `<leader>bd` | Fermer le buffer courant |
| `<leader>bp` | Épingler ou désépingler le buffer |
| `<leader>sv` / `<leader>sh` | Diviser verticalement / horizontalement |
| `<leader>se` | Égaliser la taille des fenêtres |
| `<leader>sx` | Fermer la fenêtre courante |
| `<leader>to` / `<leader>tx` | Créer / fermer un onglet |
| `<leader>tn` / `<leader>tp` | Onglet suivant / précédent |
| `<leader>tf` | Ouvrir le fichier courant dans un nouvel onglet |

## LSP et code

Ces raccourcis sont disponibles lorsqu'un serveur LSP est attaché au buffer.

| Raccourci | Action |
| --- | --- |
| `gd` / `gD` | Aller à la définition / déclaration |
| `gi` / `gy` | Aller à l'implémentation / définition du type |
| `gr` | Afficher les références |
| `K` | Afficher la documentation du symbole |
| `<leader>ca` | Exécuter une action de code |
| `<leader>cr` | Renommer le symbole |
| `<C-k>` en mode insertion | Afficher la signature de la fonction |
| `<leader>co` | Organiser les imports TypeScript, Kotlin, etc. |
| `<leader>cd` ou `gl` | Afficher le diagnostic de la ligne |
| `<leader>cR` | Redémarrer les serveurs LSP |
| `<leader>cf` | Formater le fichier ou la sélection |
| `<leader>uh` | Afficher ou masquer les inlay hints |

## Diagnostics et listes

| Raccourci | Action |
| --- | --- |
| `[d` / `]d` | Diagnostic précédent / suivant |
| `<leader>xx` | Ouvrir les diagnostics du projet dans Trouble |
| `<leader>xX` | Ouvrir les diagnostics du buffer dans Trouble |
| `<leader>cs` | Ouvrir les symboles du fichier dans Trouble |
| `<leader>cl` | Ouvrir les définitions et références LSP dans Trouble |
| `<leader>xL` | Ouvrir la location list dans Trouble |
| `<leader>xQ` | Ouvrir la quickfix list dans Trouble |

## Kotlin et Gradle

Le serveur `kotlin_lsp` officiel de Kotlin est installé par Mason. Son premier
démarrage peut prendre quelques secondes pendant l'import et l'indexation du
projet Gradle.

| Raccourci | Action |
| --- | --- |
| `<leader>kb` | Lancer `./gradlew build` |
| `<leader>kt` | Lancer `./gradlew test` |
| `<leader>kf` | Tester la classe du fichier Kotlin courant |
| `<leader>kr` | Lancer `./gradlew bootRun` |
| `<leader>kc` | Lancer `./gradlew clean` |
| `<leader>ko` | Organiser les imports Kotlin |

Les tâches s'ouvrent dans un terminal Snacks à la racine du projet. Pour de
meilleurs résultats, lancer Neovim depuis un projet contenant `gradlew`,
`settings.gradle.kts` ou `build.gradle.kts`.

## TypeScript et scripts Node

`tsgo` fournit par défaut les fonctions LSP dans l'éditeur. `:TypeScriptLsp`
ou `<leader>cT` permet de choisir `tsgo` ou l'ancien `ts_ls` pour la racine du
projet courant. Le choix persiste localement dans l'état Neovim et ne modifie
aucun fichier du dépôt. La validation complète reste séparée : elle utilise le
script `typecheck` du package lorsqu'il existe, sinon le `tsc --noEmit` installé
localement dans `node_modules`.

Lorsqu'un projet déclare Oxlint dans son `package.json` ou possède une
configuration Oxlint, celui-ci remplace automatiquement ESLint et le lint de
Biome dans l'éditeur. De même, un `dprint.json` donne la priorité à dprint pour
le formatage ; Biome et Prettier restent disponibles pour les autres projets.
Les exécutables installés dans le projet sont toujours préférés aux versions de
secours fournies par Mason.

Les commandes utilisent le `package.json` le plus proche du fichier courant.
Le gestionnaire de paquets est détecté automatiquement à partir du lockfile ou
du champ `packageManager` : npm, pnpm, Yarn et Bun sont pris en charge.

| Raccourci | Action |
| --- | --- |
| `<leader>rs` | Choisir et lancer un script de `package.json` |
| `<leader>cT` | Choisir `tsgo` ou `ts_ls` pour le projet courant |
| `<leader>rc` | Valider le package avec `typecheck` ou `tsc --noEmit` |
| `<leader>rt` | Lancer le script `test` du package |
| `<leader>rf` | Tester uniquement le fichier courant |
| `<leader>rl` | Relancer la dernière tâche |

Biome est utilisé lorsqu'un fichier `biome.json` ou `biome.jsonc` existe.
Prettier est utilisé lorsqu'une configuration Prettier est présente, y compris
dans le champ `prettier` de `package.json`. Sinon, Conform utilise le formatage
LSP en dernier recours.

## Complétion

Blink affiche les propositions LSP, chemins, buffers et snippets.

| Raccourci | Action |
| --- | --- |
| `<C-Space>` | Ouvrir la complétion ou sa documentation |
| `<C-n>` / `<C-p>` | Proposition suivante / précédente |
| `<CR>` | Accepter la proposition |
| `<C-b>` / `<C-f>` | Faire défiler la documentation |
| `<C-l>` | Accepter la suggestion Supermaven |
| `<M-l>` | Accepter un mot de la suggestion Supermaven |
| `<C-]>` | Masquer la suggestion Supermaven |

## Édition et outils

| Raccourci | Action |
| --- | --- |
| `jk` ou `<C-c>` | Quitter le mode insertion |
| `J` / `K` en mode visuel | Déplacer la sélection vers le bas / haut |
| `<` / `>` en mode visuel | Indenter sans perdre la sélection |
| `<leader>d` | Supprimer sans remplacer le registre de copie |
| `x` | Supprimer un caractère sans remplacer le registre de copie |
| `gsa` / `gsd` / `gsr` | Ajouter / supprimer / remplacer une paire entourante |
| `zR` / `zM` | Ouvrir / fermer tous les replis |
| `<leader>uu` | Afficher l'historique des modifications |
| `<leader>tt` | Ouvrir ou fermer le terminal |
| `<leader>gg` | Ouvrir LazyGit |
| `<leader>ce` | Entourer avec une abréviation Emmet |
| `<leader>pi` | Coller une image depuis le presse-papiers |
| `<leader>nh` | Afficher l'historique des notifications |
| `<leader>un` | Masquer les notifications |
| `<C-c>` en mode normal | Effacer le surlignage de la recherche |

## Commandes utiles

| Commande | Action |
| --- | --- |
| `:Lazy` | Gérer et mettre à jour les plugins |
| `:Mason` | Gérer les serveurs LSP et outils externes |
| `:LspInfo` | Afficher les serveurs configurés et attachés |
| `:TypeScriptLsp [tsgo\|ts_ls]` | Choisir le LSP TypeScript du projet courant |
| `:ConformInfo` | Afficher le formateur sélectionné pour le fichier |
| `:checkhealth` | Lancer le diagnostic général de Neovim |
| `:messages` | Afficher les derniers messages de Neovim |

## Thème du bureau

Neovim utilise la palette active partagée avec Niri, GTK, Spotify, le terminal et les
outils du bureau. Le sélecteur comprend notamment Elysia Light, Elysia Dark et
Nord, avec sa palette polaire bleu-gris.

| Raccourci ou commande | Action |
| --- | --- |
| `Super+T` | Ouvrir le sélecteur des thèmes du bureau |
| `apply-theme elysia-light` | Appliquer Elysia Light sur tout le bureau |
| `apply-theme elysia-dark` | Appliquer Elysia Dark sur tout le bureau |
| `apply-theme nord` | Appliquer Nord sur tout le bureau |

Une instance Neovim déjà ouverte doit être redémarrée pour recharger toute la
palette. Le détail et les fichiers Vivaldi sont dans
`~/.config/theme/README.md`.
