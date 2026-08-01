# Dotfiles d’Ugzher

Configuration personnelle Fedora/Niri avec les thèmes Obsidian Rose,
Ultraviolet et Night.

## Contenu

- shell Zsh, Starship, Atuin et fzf-tab ;
- Niri, Quickshell, Waybar, Fuzzel, Mako et Swaylock ;
- Kitty, Zellij, tmux et les outils modernes du terminal ;
- Neovim et son thème généré ;
- Yazi, Posting, Harlequin, lazygit et mise ;
- GTK 3/4, scripts personnels et fond d’écran utilisé par les thèmes.

Les caches, historiques, bases, binaires, plugins WASM et identifiants sont
volontairement exclus. Les configurations Kubernetes, VPN, Fnox, navigateurs,
Codex et les clés GPG/SSH ne sont jamais copiées.

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
indépendant dans `~/.config/nvim`.

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

## Après restauration

Les applications et plugins restent à installer séparément. Les trois plugins
Zellij sont volontairement absents du dépôt et peuvent être téléchargés depuis
leurs releases officielles :

- [zjstatus](https://github.com/dj95/zjstatus)
- [room](https://github.com/rvcas/room)
- [zellij-forgot](https://github.com/karimould/zellij-forgot)

La liste et l’utilisation des outils se trouvent dans
`home/.config/terminal-tools.md`.

