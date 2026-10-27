# Dotfiles d’Ugzher

Configuration personnelle Fedora/Niri et environnement terminal partagé avec
les serveurs. Le dépôt public conserve le déploiement du bureau ; l’historique
mise privé synchronise automatiquement les fichiers de terminal modifiés en
place.

## Organisation

- `mise.toml` déploie les fichiers propres au desktop depuis `home/` avec le
  groupe `desktop` ;
- mise suit directement Zsh, tmux, Git, Atuin, Starship, lazygit, dust, Yazi,
  Neovim et sa propre configuration ;
- le service utilisateur `mise-history` sauvegarde les modifications et les
  échange avec le dépôt privé configuré par `mise dot origin set` ;
- `inventory/` garde la liste des paquets Fedora, Flatpaks et services
  utilisateur.

Les caches, historiques applicatifs, bases, binaires, plugins WASM et
identifiants sont exclus. Les configurations Kubernetes, VPN, Fnox,
navigateurs, Codex et clés GPG/SSH ne sont jamais copiées.

## Utilisation quotidienne

Les fichiers partagés se modifient normalement dans `$HOME`. Le watcher mise
les enregistre et les synchronise sans commande manuelle. Pour forcer une
sauvegarde, un échange immédiat et mettre à jour les inventaires :

```bash
dots
```

Pour publier aussi les changements du dépôt desktop :

```bash
dots --push "feat: mettre à jour le bureau"
```

Commandes utiles :

```bash
mise dot status
mise dot history
mise dot sync
mise dot pull
```

## Restaurer le desktop

Après avoir installé mise et cloné ce dépôt dans `~/dotfiles`, prévisualiser :

```bash
cd ~/dotfiles
./restore.sh
```

Puis appliquer le groupe desktop et activer le watcher :

```bash
./restore.sh --apply
```

## Ajouter une autre machine

Une fois mise installé et l’accès Git au dépôt privé configuré :

```bash
mise bootstrap --adopt git@github.com:Ugzh/dotfiles-sync.git --replace-history --take-remote-all --yes
```

Cette commande restaure les fichiers suivis, installe le service de
surveillance déclaré dans la configuration partagée et connecte la machine au
même historique. Les fichiers desktop ne sont pas appliqués sur le serveur.

La liste et l’utilisation des outils du terminal se trouvent dans
`home/.config/terminal-tools.md`.
