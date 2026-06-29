# Dotfiles — xmb03

Personal i3wm dotfiles with pywal-driven colorscheming.

<p align="center">
  <img src="pictures/desktop.png" alt="Desktop" width="49%">
  <img src="pictures/neovim.png" alt="Neovim" width="49%">
</p>

## Features

- **i3** — modular config split into `user/` (personal) and `system/` (distribution-agnostic)
- **pywal** — single wallpaper pick changes colors across the entire desktop (kitty, rofi, i3, zathura, nvim, zsh, gtk)
- **rofi** — app launcher, clipboard manager (`greenclip`), window switcher
- **Neovim** — LazyVim distribution with `neopywal.nvim` colorscheme
- **i3status-rust** — status bar with keyboard layout, volume, backlight, clock
- **Zsh** — autosuggestions + syntax highlighting with dynamic pywal colors

## Structure

| Directory | Description |
|---|---|
| [`i3/`](i3/README.md) | i3wm modular config (user/ + system/ layers) |
| [`kitty/`](kitty/README.md) | Terminal emulator |
| [`nvim/`](nvim/README.md) | Neovim (LazyVim + neopywal) |
| [`rofi/`](rofi/README.md) | App launcher / clipboard / window switcher |
| [`zathura/`](zathura/README.md) | PDF viewer |
| [`gtk-3.0/`](gtk-3.0/README.md) | GTK3 settings + dark theme |
| [`gtk-4.0/`](gtk-4.0/README.md) | GTK4 settings + dark theme |
| [`fontconfig/`](fontconfig/README.md) | Font aliases → JetBrainsMono Nerd Font |
| [`shell/`](shell/README.md) | Zsh, Bash, Xresources, xprofile |
| [`redshift/`](redshift/README.md) | Blue light filter |
| [`wal/`](wal/README.md) | pywal template for zathura |
| [`dconf/`](dconf/README.md) | GSettings dump |

## Keybindings

| Key | Action |
|---|---|
| `$mod+d` | Rofi app launcher |
| `$mod+v` | Rofi clipboard manager (greenclip) |
| `$mod+Tab` | Rofi window switcher |
| `$mod+w` | Firefox |
| `$mod+a` | Wallpaper picker |
| `Print` | Full screenshot (flameshot) |
| `$mod+Shift+s` | Region screenshot (flameshot) |
| `$mod+j/k/l/;` | Focus (vim-style, also arrows) |
| `$mod+Shift+j/k/l/;` | Move window |
| XF86Audio{Lower,Raise,Mute}Volume | Volume controls |
| `$mod+r` | Resize mode |
| `$mod+1-0` | Workspace switch |

## Color Scheme

The entire desktop is themed by **pywal** — run the wallpaper picker (`$mod+a`) to select an image, and pywal generates a 16-color palette that applies to:

- **kitty** — `include colors-kitty.conf`
- **rofi** — `@import colors-rofi-dark.rasi`
- **i3** — `set_from_resource` via Xresources
- **zathura** — pywal template
- **neovim** — neopywal.nvim
- **zsh** — syntax highlighting colors from wal variables

## Applications

| App | Purpose |
|---|---|
| i3 | Window manager |
| kitty | Terminal |
| neovim | Editor (LazyVim) |
| rofi | Launcher / clipboard / window switcher |
| i3status-rust | Status bar |
| zathura | PDF viewer |
| dunst | Notifications |
| flameshot | Screenshots |
| greenclip | Clipboard manager |
| feh | Wallpaper setter |
| red shift | Blue light filter |
| udiskie | USB auto-mount |
| i3lock | Lock screen |

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/xmb03/i3-dots/main/bootstrap.sh)
```

Or manually:

```bash
git clone git@github.com:xmb03/i3-dots.git ~/.config/dotfiles
# symlink or copy configs as needed
# set wallpaper with $mod+a or run ~/.fehbg
```

## Hardware

- **Monitor:** DP-0 1920×1200 @ 165Hz
- **Touchpad:** FTCS1000:01 — natural scrolling
- **Wallpaper:** gruvbox_image55.png

## License

MIT
