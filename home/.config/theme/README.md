# Obsidian Rose desktop theme

`obsidian-rose` is the active desktop palette: plum-black surfaces, fuchsia
keywords, lavender types and a restrained acid-green accent. Apply it with:

```sh
apply-theme obsidian-rose
```

The source palette lives in `presets/obsidian-rose.env`. `current.env` is
generated from it. The script then updates Niri, GTK 3/4, the cursor, Waybar,
Fuzzel, Mako, Swaylock, Kitty, tmux and Neovim.

Vivaldi themes are generated in `vivaldi/*.zip`. When Vivaldi is closed,
`apply-theme` also registers the selected theme in its profile and keeps a
one-time `Preferences.before-cyberdream` backup. If Vivaldi was open during
the initial setup, import both ZIP files from Settings > Themes > Library >
Open Theme.
