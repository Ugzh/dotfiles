# Dotfiles d’Ugzher

Configuration personnelle Fedora/Niri, thèmes de bureau et inventaire des
logiciels nécessaires pour reconstruire la machine.

## Contenu

- shell Zsh, Starship, Atuin et fzf-tab ;
- Niri, Quickshell, Theme Picker, Waybar, Fuzzel, Mako, GTKLock et Swaylock ;
- Kitty, Zellij, tmux et les outils modernes du terminal ;
- Neovim et son thème généré ;
- Yazi, Posting, Harlequin, lazygit et mise ;
- GTK 3/4, portails XDG, Spicetify, scripts et lanceurs personnels ;
- fonds d’écran utilisés par les thèmes ;
- paquets Fedora installés manuellement, applications Flatpak et services
  utilisateur activés dans `inventory/`.

Les caches, historiques, bases, binaires, plugins WASM et identifiants sont
volontairement exclus. Les extensions Spicetify téléchargées, configurations
Kubernetes, VPN, Fnox, navigateurs, Codex et clés GPG/SSH ne sont jamais
copiés.

## Enregistrer les modifications

```bash
cd ~/dotfiles
./sync.sh
git diff
git add .
git commit -m "update configuration"
```

`sync.sh` copie uniquement la liste blanche déclarée dans le script. Neovim
est copié sans son répertoire `.git`, afin de conserver intact son dépôt local
indépendant dans `~/.config/nvim`. Il régénère également les trois inventaires
de `inventory/`.

## Restaurer sur une machine

Cloner le dépôt dans `~/dotfiles`, puis afficher d’abord l’aperçu :

```bash
cd ~/dotfiles
./restore.sh
```

Appliquer ensuite la restauration :

```bash
./restore.sh --apply
```

Les fichiers existants remplacés sont conservés dans
`~/.dotfiles-backup/<date>`. Le script ne supprime pas les autres fichiers de
la machine.

Les inventaires sont volontairement informatifs : la restauration ne lance
pas automatiquement `dnf`, Flatpak ou `systemctl`, afin de ne pas modifier une
nouvelle machine sans validation.

## Après restauration

Les applications et plugins restent à installer séparément. Les trois plugins
Zellij sont volontairement absents du dépôt et peuvent être téléchargés depuis
leurs releases officielles :

- [zjstatus](https://github.com/dj95/zjstatus)
- [room](https://github.com/rvcas/room)
- [zellij-forgot](https://github.com/karimould/zellij-forgot)

La liste et l’utilisation des outils se trouvent dans
`home/.config/terminal-tools.md`.
