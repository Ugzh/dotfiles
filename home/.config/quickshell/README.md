# Barre Quickshell moderne

Cette configuration reprend les fonctions actives de la Waybar existante :

- lanceur Fuzzel et terminal Kitty ;
- espaces de travail Niri par écran ;
- lecteur MPRIS avec contrôles et visualiseur Cava ;
- profils WireGuard `ugo-public` et `ugo-gpu` ;
- luminosité, batterie et volume PipeWire ;
- mémoire, CPU et mises à jour Fedora ;
- horloge et zone de notification.

## Essai manuel

Laisser Waybar active et lancer :

```sh
qs -p ~/.config/quickshell
```

Arrêter l'essai :

```sh
qs -p ~/.config/quickshell kill
```

La configuration Niri peut ensuite remplacer `spawn-at-startup "waybar"` par
`spawn-at-startup "qs"`.
