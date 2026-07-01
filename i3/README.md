# i3wm config

Modular i3 configuration with pywal colors, custom scripts, and i3status-rust bar.

## Structure

```
~/.config/i3/
├── config              # Entry point — $mod, font, includes
├── user/               # User-specific settings
│   ├── settings.conf   # Borders, window colors (pywal Xresources)
│   ├── autostart.conf  # dunst, xss-lock, xrdb, redshift, udiskie
│   ├── binds.conf      # flameshot, rofi, firefox, wallpaper picker
│   ├── bar.conf        # i3status-rust with themed colors
│   └── monitor.conf    # xrandr — display setup
├── system/             # Distribution-agnostic settings
│   ├── settings.conf   # floating_modifier, tiling_drag, workspaces
│   ├── autostart.conf  # dex (XDG autostart), nm-applet
│   └── binds.conf      # WM controls, resize mode, media keys
├── scripts/
│   ├── rofi-wallpaper  # GUI wallpaper picker (rofi + pywal + feh)
│   └── microphone.sh   # Pipewire mic mute notifications
├── i3status-rs/
│   └── config.toml     # Bar blocks: keyboard, backlight, sound, music, net, time
└── rofi/nowplaying/    # rofi-music-control: album art, playback controls
    ├── nowplaying.sh   # Launch script
    ├── nowplaying.rasi # Rofi theme (pywal colors)
    ├── fallback_album_art.png
    └── album_art.png   # Generated cache
```

## Dependencies

### Core
| Package | Purpose |
|---------|---------|
| `i3-wm` | Window manager |
| `i3status-rust` | Bar |
| `rofi` | App launcher / wallpaper picker |
| `dunst` | Notifications |
| `pywal` | Dynamic colors from wallpaper |
| `feh` | Wallpaper setter |
| `xss-lock` | Screen lock on suspend |
| `i3lock` | Lock screen |
| `redshift` | Blue light filter |
| `udiskie` | Auto-mount USB |
| `dex` | XDG autostart |
| `nm-applet` | NetworkManager tray |
| `flameshot` | Screenshots |
| `greenclip` | Clipboard manager |
| `pulseaudio` / `pipewire` | Sound |
| `xdotool` | Keyboard layout toggle |
| `playerctl` | MPRIS media player control |
| `curl` | Album art download |
| `base64` | Base64 album art decoding |

### Optional
| Package | Purpose |
|---------|---------|
| `picom` | Compositor (disabled by default) |
| `wal-telegram` | Telegram theme from pywal |
| `pw-mon` / `wpctl` (pipewire) | Mic monitoring script |

## Install

```bash
# Clone into ~/.config/i3
git clone <repo-url> ~/.config/i3

# Ensure Xresources is loaded on login
echo 'xrdb -merge ~/.Xresources' >> ~/.xinitrc

# Restart i3: $mod+Shift+r
```

## Keybindings (user)

| Key | Action |
|-----|--------|
| `Print` | Flameshot fullscreen |
| `$mod+Shift+s` | Flameshot GUI |
| `$mod+d` | Rofi app launcher |
| `$mod+v` | Greenclip clipboard |
| `$mod+Tab` | Rofi window switcher |
| `$mod+a` | Wallpaper picker |
| `$mod+w` | Firefox |
| `$mod+m` | Rofi music control (nowplaying) |

## Home Manager / NixOS migration

This config is structured to map cleanly to `programs.i3` / `home-manager` modules:

- `user/` → `i3.config` or `extraConfig`
- `system/` → distribution-level config
- `scripts/` → `home.file."scripts/..."` or `pkgs.writeShellScript`
- `i3status-rs/config.toml` → `programs.i3status-rust`
- Dependencies → `home.packages = [ ... ]`
- Xresources colors → `xresources.properties."i3wm.colorN"`
- Autostart services → `systemd.user.services.*`
