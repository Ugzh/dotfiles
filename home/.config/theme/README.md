# Desktop themes

Press `Super+T` to open a Fuzzel selector for the desktop palettes.

Press `Super+Shift+W` to open the visual theme-and-wallpaper selector. To replace
the wallpaper associated with the active palette, run `wallpaper-menu`; each
selection is stored in `wallpapers/<theme-name>.env`.

## Associate a wallpaper with a theme

The easiest method is:

1. Apply the theme with `Super+T` or `apply-theme <theme-name>`.
2. Run `wallpaper-menu` and choose an image.
3. Switch away from the theme and back to it to verify that the association is
   restored.

The selector writes a per-theme override to
`~/.config/theme/wallpapers/<theme-name>.env`. It has the following format:

```sh
THEME_WALLPAPER=/home/Ugzher/Pictures/Wallpapers/example.jpg
THEME_WALLPAPER_MODE=fill
```

Supported static modes are `fill`, `fit`, `stretch`, `center` and `tile`.
Use an absolute path and make sure the file exists. `apply-theme` and
`apply-wallpaper` load this override after the preset, so it takes precedence
over `THEME_WALLPAPER` in `presets/<theme-name>.env`.

To set the built-in default of a theme, edit the same two variables in its
`presets/<theme-name>.env`. The per-theme override still takes precedence; remove
`wallpapers/<theme-name>.env` if you want to fall back to the preset default.

Apply or troubleshoot the wallpaper directly with:

```sh
apply-theme <theme-name>
/home/Ugzher/.local/bin/apply-wallpaper
```

`apply-wallpaper` uses `swaybg` for static images and `mpvpaper` for animated
images or videos.

The active mapping also generates
`~/.local/share/theme-sync/login-background.jpg`. Swaylock and gtklock use this
still image, and `theme-greeter-background.path` mirrors it to greetd for the
next login or reboot. Animated wallpapers use a captured frame on lock and
login screens.

- `obsidian-rose`: plum-black surfaces, fuchsia, lavender and acid green.
- `seoul256-dark`: soft charcoal surfaces, muted blue, cyan, green, rose and
  gold accents from Seoul256 Dark, paired with the blue-gray Nordzy cursor.
- `cool-panda`: near-black surfaces with Cool Panda's turquoise, periwinkle,
  violet and pink accents, paired with a mauve Catppuccin cursor.
- `melange-dark`: warm earth-brown surfaces with amber control-flow accents
  and cool blue-green data accents from the official Melange Dark palette.

The initial per-theme mappings use `gruvbox_dark.jpg` for Seoul256 Dark and
Melange Dark, and `catppuccin.png` for Cool Panda. Apply a theme, then run `wallpaper-menu`
to replace and save its wallpaper independently.

Palette references:

- Seoul256 Dark: https://zed-themes.com/themes/0iAN5uHijmQtfvf9fWWYV?name=Seoul256%20Dark
- Cool Panda: https://zed-themes.com/themes/-EAb_Barl5mtb79jGci2s?name=Cool%20Panda
- Melange Dark: https://github.com/savq/melange-nvim/blob/master/melange_dark.json

Each desktop palette applies its matching cursor automatically. Gruvbox Soft
uses rounded Bibata cursors built in the matching dark and light palettes.
- `catppuccin-mocha`: deep ink surfaces with the mauve, lavender, blue, green
  and teal accents from the Catppuccin Mocha palette.
- `gruvbox-soft-dark`: Gruvbox's warm, low-contrast Dark Soft palette.
- `gruvbox-soft-light`: Gruvbox's warm, low-contrast Light Soft palette.
- `elysia-light`: cool-white surfaces with Elysia-inspired violet, blue, sand
  and green pastels.
- `elysia-dark`: ink-blue surfaces with brighter variants of the same Elysia
  pastels.
- `nord`: Polar Night surfaces, Snow Storm text, Frost blues and Aurora
  accents from the canonical Nord palette, paired with Nordzy Cursors.

Apply one directly with `apply-theme melange-dark`, `apply-theme seoul256-dark`, `apply-theme cool-panda`
or another preset.
Source palettes live in `presets/*.env` and
`current.env` is generated from the selected preset. The script then updates
Niri, GTK 3/4, the cursor, Waybar, Quickshell, Fuzzel, Mako, Swaylock, Kitty,
tmux, Yazi, Neovim and the Spicetify-powered Spotify client.

Vivaldi themes are generated in `vivaldi/*.zip`. When Vivaldi is closed,
`apply-theme` also registers the selected theme in its profile and keeps a
one-time `Preferences.before-cyberdream` backup. If Vivaldi was open during
the initial setup, import both ZIP files from Settings > Themes > Library >
Open Theme.
