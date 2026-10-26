# Cheat sheet Neovim

Cette fiche recense les raccourcis personnalisés définis dans cette
configuration et les commandes essentielles des interfaces qu'elle active.

## Notation et aide

- `<leader>` = `Espace`.
- `<C-x>` = `Ctrl+x`, `<S-x>` = `Maj+x`, `<M-x>` = `Alt+x`.
- Les majuscules comptent : `<leader>ef` et `<leader>eF` sont différents.
- Après `Espace`, attendre environ 350 ms pour afficher Which-key.
- `<leader>fk` recherche tous les raccourcis actuellement chargés.

## Recherche et navigation

| Raccourci | Mode | Action |
| --- | --- | --- |
| `<leader><space>` | Normal | Recherche intelligente |
| `<leader>ff` | Normal | Rechercher un fichier |
| `<leader>fr` | Normal | Ouvrir un fichier récent |
| `<leader>fs` | Normal | Rechercher du texte dans le projet |
| `<leader>fc` | Normal / visuel | Rechercher le mot ou la sélection |
| `<leader>fb` | Normal | Rechercher parmi les buffers |
| `<leader>fh` | Normal | Rechercher dans l'aide |
| `<leader>fk` | Normal | Rechercher un raccourci |
| `<leader>fd` | Normal | Rechercher dans les diagnostics |
| `<leader>fm` | Normal | Rechercher une méthode du fichier |
| `<leader>fR` | Normal / visuel | Rechercher et remplacer avec Grug Far |
| `s` | Normal | Sauter vers une position visible avec Mini Jump2d |
| `n` / `N` | Normal | Résultat de recherche suivant / précédent, recentré |
| `<C-d>` / `<C-u>` | Normal | Descendre / monter d'une demi-page, recentré |
| `<leader>;` | Normal | Choisir un symbole dans le fil d'Ariane |
| `[;` / `];` | Normal | Début du contexte / contexte suivant |

## Fichiers avec Mini Files

`<leader>ef` ouvre ou ferme Mini Files autour du fichier courant. Les colonnes
de gauche sont les dossiers parents, la colonne centrale est le dossier actif
et celle de droite affiche l'enfant ou l'aperçu. `<leader>eF` conserve
l'explorateur Snacks centré comme alternative.

| Raccourci | Action dans Mini Files |
| --- | --- |
| `<leader>ef` | Ouvrir / fermer Mini Files |
| `<leader>eF` | Ouvrir l'explorateur Snacks |
| `j` / `k` | Descendre / monter |
| `l` | Entrer dans le dossier ou ouvrir le fichier |
| `L` | Entrer et fermer les colonnes situées à gauche |
| `h` | Revenir au dossier parent |
| `H` | Revenir au parent et fermer les colonnes de droite |
| `q` | Fermer l'explorateur |
| `g?` | Afficher l'aide de Mini Files |
| `m` / `'` | Poser une marque / aller à une marque |
| `<BS>` | Réinitialiser la navigation |
| `@` | Révéler le dossier de travail courant |
| `<` / `>` | Réduire les colonnes à gauche / à droite |
| `=` | Appliquer les changements au système de fichiers |

Les fichiers se manipulent comme des lignes de texte : modifier un nom pour
renommer, ajouter une ligne pour créer, `dd` pour supprimer, et copier/coller
une ligne pour copier ou déplacer. Rien n'est appliqué avant `=`. Les
suppressions sont envoyées dans la corbeille interne de Mini Files.

## Entourer, remplacer ou supprimer des délimiteurs

La configuration utilise `nvim-surround` et ses commandes proches de
vim-surround.

### Ajouter des guillemets autour d'un mot

Placer le curseur sur le mot, puis taper `ysiw"` :

```text
salut  ->  "salut"
```

- `ys` demande d'ajouter une paire entourante ;
- `iw` sélectionne le mot courant (`inner word`) ;
- `"` choisit les guillemets comme délimiteurs.

Le même principe fonctionne avec `ysiw'`, `ysiw)`, `ysiw]` et `ysiw}`.

| Raccourci | Action |
| --- | --- |
| `cs{ancien}{nouveau}` | Remplacer les délimiteurs autour du curseur |
| `ds{délimiteur}` | Supprimer les délimiteurs |
| `ys{mouvement}{délimiteur}` | Ajouter des délimiteurs autour d'un mouvement |
| `yss{délimiteur}` | Entourer la ligne courante |
| `S{délimiteur}` | Entourer la sélection visuelle |
| `<C-g>s{délimiteur}` | Ajouter des délimiteurs en mode insertion |

Exemples avec le curseur placé dans le texte :

| Avant | Commande | Après |
| --- | --- | --- |
| `"salut"` | `cs"'` | `'salut'` |
| `{salut}` | `cs}]` | `[salut]` |
| `'salut'` | `ds'` | `salut` |
| `salut` | `ysiw"` | `"salut"` |
| `salut monde` | `yss)` | `(salut monde)` |

Pour `()`, `{}` et `[]`, utiliser le caractère fermant pour obtenir une paire
compacte. Le caractère ouvrant ajoute des espaces : `ysiw)` donne `(mot)`,
tandis que `ysiw(` donne `( mot )`. `q` désigne la paire de guillemets la plus
proche, donc `csq'` permet aussi de convertir les guillemets voisins en
apostrophes.

## Édition

| Raccourci | Mode | Action |
| --- | --- | --- |
| `jk` / `<C-c>` | Insertion | Revenir au mode normal |
| `J` / `K` | Visuel | Déplacer la sélection vers le bas / haut |
| `<` / `>` | Visuel | Indenter à gauche / droite sans perdre la sélection |
| `p` | Visuel | Remplacer la sélection sans écraser le registre copié |
| `J` | Normal | Joindre la ligne suivante sans déplacer la vue |
| `<leader>Y` | Normal | Copier la ligne dans le presse-papiers système |
| `<leader>d` | Normal / visuel | Supprimer sans écraser le registre copié |
| `x` | Normal | Supprimer un caractère sans écraser le registre copié |
| `Q` | Normal | Désactivé |
| `<C-c>` | Normal | Effacer le surlignage de recherche |
| `zR` / `zM` | Normal | Ouvrir / fermer tous les replis |
| `<leader>uu` | Normal | Afficher l'arbre des modifications |
| `<leader>pi` | Normal | Coller une image depuis le presse-papiers |
| `<leader>ce` | Normal / visuel | Entourer avec une abréviation Emmet |

## Buffers, fenêtres et onglets

| Raccourci | Action |
| --- | --- |
| `<S-h>` / `<S-l>` | Buffer précédent / suivant |
| `<leader>bd` | Fermer le buffer courant |
| `<leader>bp` | Épingler / désépingler le buffer |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Fenêtre ou pane Zellij à gauche / bas / haut / droite |
| `<leader>sv` / `<leader>sh` | Diviser verticalement / horizontalement |
| `<leader>se` | Égaliser la taille des fenêtres |
| `<leader>sx` | Fermer la fenêtre courante |
| `<leader>to` / `<leader>tx` | Créer / fermer un onglet Neovim |
| `<leader>tn` / `<leader>tp` | Onglet suivant / précédent |
| `<leader>tf` | Ouvrir le fichier courant dans un nouvel onglet |

## LSP et code

Les raccourcis marqués LSP apparaissent lorsqu'un serveur est attaché au
fichier courant.

| Raccourci | Mode | Action |
| --- | --- | --- |
| `gd` / `gD` | LSP | Définition / déclaration |
| `gi` / `gy` | LSP | Implémentation / définition du type |
| `gr` | LSP | Références |
| `K` | LSP | Documentation du symbole |
| `<leader>ca` | LSP normal / visuel | Action de code |
| `1` à `9` | Sélecteur d'action | Exécuter directement l'action correspondante |
| `<leader>cr` | LSP | Renommer avec aperçu en direct |
| `<C-k>` | LSP, insertion | Signature de la fonction |
| `<leader>co` | LSP | Organiser les imports |
| `<leader>cd` / `gl` | Normal | Diagnostic de la ligne |
| `[d` / `]d` | Normal | Diagnostic précédent / suivant |
| `<leader>cR` | LSP | Redémarrer le serveur |
| `<leader>cf` | Normal / visuel | Formater le fichier ou la sélection |
| `<leader>uh` | LSP | Afficher / masquer les inlay hints |
| `<leader>uv` | LSP | Afficher / masquer les diagnostics multilignes |
| `<leader>cT` | Normal | Choisir `auto`, `tsgo` ou `ts_ls` pour le projet |

## Diagnostics, TODO et listes

| Raccourci | Action |
| --- | --- |
| `<leader>xx` | Diagnostics du projet dans Trouble |
| `<leader>xX` | Diagnostics du buffer dans Trouble |
| `<leader>cs` | Symboles du fichier dans Trouble |
| `<leader>cl` | Définitions et références LSP dans Trouble |
| `<leader>xL` | Location list dans Trouble |
| `<leader>xQ` | Quickfix list dans Trouble |
| `<leader>xt` | TODO du projet dans Trouble |
| `[t` / `]t` | TODO précédent / suivant |

## Complétion et suggestions

| Raccourci | Action |
| --- | --- |
| `<C-Space>` | Ouvrir la complétion ou sa documentation |
| `<C-n>` / `<C-p>` | Proposition suivante / précédente |
| `<CR>` | Accepter la proposition |
| `<C-b>` / `<C-f>` | Faire défiler la documentation |
| `<C-l>` | Accepter la suggestion Supermaven |
| `<M-l>` | Accepter un mot de la suggestion Supermaven |
| `<C-]>` | Masquer la suggestion Supermaven |

## Git

| Raccourci | Mode | Action |
| --- | --- | --- |
| `<leader>gg` | Normal | Ouvrir LazyGit |
| `[h` / `]h` | Normal | Changement Git précédent / suivant |
| `<leader>gp` | Normal | Prévisualiser le changement courant |
| `<leader>gs` | Normal / visuel | Indexer le changement ou la sélection |
| `<leader>gr` | Normal / visuel | Annuler le changement ou la sélection |
| `<leader>gb` | Normal | Afficher / masquer le blame de la ligne |
| `<leader>gv` | Normal | Examiner les modifications dans Diffview |
| `<leader>gV` | Normal | Historique Git du fichier courant |

## Sessions, tâches et terminal

| Raccourci | Action |
| --- | --- |
| `<leader>qs` | Sauvegarder la session du projet |
| `<leader>qr` | Restaurer la session du projet |
| `<leader>ql` | Choisir une session |
| `<leader>qd` | Supprimer une session |
| `<leader>tt` | Ouvrir / fermer le terminal Snacks |
| `<leader>rs` | Choisir un script de `package.json` |
| `<leader>rc` | Vérifier les types du package |
| `<leader>rt` | Lancer les tests du package |
| `<leader>rf` | Tester le fichier courant |
| `<leader>rl` | Relancer la dernière tâche |
| `<leader>kb` | Lancer `./gradlew build` |
| `<leader>kt` | Lancer `./gradlew test` |
| `<leader>kf` | Tester la classe Kotlin courante |
| `<leader>kr` | Lancer `./gradlew bootRun` |
| `<leader>kc` | Lancer `./gradlew clean` |
| `<leader>ko` | Organiser les imports Kotlin |

## Interface et notifications

| Raccourci | Action |
| --- | --- |
| `<leader>nh` | Historique des notifications |
| `<leader>un` | Masquer les notifications |
| `<leader>us` | Activer / désactiver le correcteur |
| `<leader>uw` | Activer / désactiver le retour à la ligne |
| `<leader>fp` | Copier le chemin du fichier courant |
| `q` | Fermer les fenêtres d'aide, quickfix, diagnostics et autres fenêtres temporaires |

## Zellij

Ces raccourcis sont chargés uniquement lorsque Neovim tourne dans Zellij.

| Raccourci | Action |
| --- | --- |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Naviguer entre panes Zellij et fenêtres Neovim |
| `<leader>zt` | Nouvel onglet Zellij |
| `<leader>zr` | Renommer l'onglet Zellij |
| `<leader>z,` / `<leader>z.` | Déplacer l'onglet Zellij à gauche / droite |

## Débogage conditionnel

Ces raccourcis ne sont chargés que si l'adaptateur JavaScript attendu existe
sur la machine.

| Raccourci | Action |
| --- | --- |
| `<leader>db` | Ajouter / retirer un point d'arrêt |
| `<leader>dg` | Exécuter jusqu'au curseur |
| `<leader>de` | Évaluer l'expression sous le curseur |
| `<F1>` | Continuer |
| `<F2>` | Entrer dans la fonction |
| `<F3>` | Passer à l'instruction suivante |
| `<F4>` | Sortir de la fonction |
| `<F5>` | Revenir en arrière |
| `<F13>` / `Maj+F1` | Redémarrer le débogage |

## Commandes utiles

| Commande | Action |
| --- | --- |
| `:Lazy` | Gérer les plugins |
| `:Mason` | Gérer les serveurs LSP et outils externes |
| `:LspInfo` | Inspecter les serveurs LSP |
| `:TypeScriptLsp [auto\|tsgo\|ts_ls]` | Choisir le serveur TypeScript |
| `:ConformInfo` | Inspecter le formateur courant |
| `:checkhealth` | Diagnostiquer Neovim et ses plugins |
| `:messages` | Afficher les derniers messages |
