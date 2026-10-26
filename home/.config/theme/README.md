# Desktop themes

Press `Super+T` to open a Fuzzel selector for the desktop palettes.

Press `Super+Shift+W` to open DMS wallpaper settings. `Mod+Shift+Return`
opens the DMS power menu, including its lock action. DMS owns the active
wallpaper and lock screen; `swww` is not required.

## Add a new theme

Fastfetch uses a fixed custom ASCII logo shared by every palette:

```text
fastfetch-logo.txt
```

The two-color logo uses Fastfetch's `$1` and `$2` placeholders. `apply-theme`
renders its path and the current palette into `~/.config/fastfetch/config.jsonc`.

After adding the preset and sprite, verify them with:

```sh
apply-theme <theme-name>
fastfetch
```

## Wallpaper management

Choose the current wallpaper with `Super+Shift+W`, or set it directly with
`dms ipc call wallpaper set /absolute/path/to/image.jpg`. The DMS lock screen
uses the wallpaper known to DMS. Ayu presets do not force a wallpaper, so
switching between them leaves the selected image in place.

Legacy presets may still define `THEME_WALLPAPER`, and per-theme files in
`wallpapers/<theme-name>.env` can override it. `apply-theme` sends those images
to DMS when such a mapping exists. The separate `apply-wallpaper` script is no
longer started by Niri. The greeter still uses the still image generated in
`~/.local/share/theme-sync/login-background.jpg` when a preset specifies one.

- `obsidian-rose`: plum-black surfaces, fuchsia, lavender and acid green.
- `seoul256-dark`: soft charcoal surfaces, muted blue, cyan, green, rose and
  gold accents from Seoul256 Dark, paired with the blue-gray Nordzy cursor.
- `cool-panda`: near-black surfaces with Cool Panda's turquoise, periwinkle,
  violet and pink accents, paired with a mauve Catppuccin cursor.
- `melange-dark`: warm earth-brown surfaces with amber control-flow accents
  and cool blue-green data accents from the official Melange Dark palette.

The initial per-theme mappings use `gruvbox_dark.jpg` for Seoul256 Dark and
Melange Dark, and `catppuccin.png` for Cool Panda. DMS can replace the current
wallpaper at any time with `Super+Shift+W`.

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
