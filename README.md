# Dotfiles d’Ugzher

Configuration personnelle Fedora/Niri, thèmes de bureau et inventaire des
logiciels nécessaires pour reconstruire la machine.

## Contenu

- shell Zsh, Starship, Atuin et fzf-tab ;
- Niri, Quickshell, Theme Picker, Waybar, Fuzzel, Mako, GTKLock et Swaylock ;
- Kitty, tmux et les outils modernes du terminal ;
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

Les fichiers de `home/` sont directement liés dans `$HOME` avec GNU Stow :
toute modification de la configuration modifie donc immédiatement le dépôt,
sans copie intermédiaire.

Pour mettre à jour les inventaires et créer un commit local :

```bash
dots
```

Pour choisir le message et pousser le commit vers GitHub :

```bash
dots --push "feat: mettre à jour le bureau"
```

`sync.sh` réapplique les liens Stow et régénère les trois inventaires de
`inventory/`. Il ne recopie aucun fichier de configuration.

## Restaurer sur une machine

Installer Stow, cloner le dépôt dans `~/dotfiles`, puis afficher d’abord
l’aperçu :

```bash
sudo dnf install stow
```

```bash
cd ~/dotfiles
./restore.sh
```

Appliquer ensuite la restauration :

```bash
./restore.sh --apply
```

Les fichiers physiques qui entrent en conflit sont déplacés dans
`~/.dotfiles-backup/stow-<date>`, puis remplacés par des liens symboliques.
Le script ne touche pas aux fichiers absents du paquet `home/`.

Les inventaires sont volontairement informatifs : la restauration ne lance
pas automatiquement `dnf`, Flatpak ou `systemctl`, afin de ne pas modifier une
nouvelle machine sans validation.

## Après restauration

La liste et l’utilisation des outils se trouvent dans
`home/.config/terminal-tools.md`.
