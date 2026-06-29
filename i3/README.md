# i3

Modular i3wm config split into `user/` and `system/` layers.

## Structure

| Path | Purpose |
|---|---|
| `config` | Entry point — `$mod Mod4`, includes all sub-configs |
| `user/settings.conf` | Keyboard repeat, border style, 16 pywal colors via `set_from_resource` |
| `user/autostart.conf` | dunst, xss-lock, xrdb, redshift, udiskie, rofi-wallpaper |
| `user/bar.conf` | i3status-rust bar at bottom, pywal colors |
| `user/binds.conf` | User keybindings — flameshot, firefox, rofi, wallpaper |
| `user/monitor.conf` | DP-0 1920×1200 @ 165Hz |
| `system/settings.conf` | Floating modifier, 10 workspaces |
| `system/autostart.conf` | dex, nm-applet |
| `system/binds.conf` | Volume, focus, resize, layout, workspace keys |
| `scripts/rofi-wallpaper` | Wallpaper picker (rofi grid → pywal → feh) |
| `scripts/powermenu.sh` | Power menu with Nerd Font icons (Lock, Logout, Suspend, Hibernate, Reboot, Shutdown) |
| `i3status-rs/config.toml` | Status bar blocks: keyboard layout, volume, backlight, time, power-off button |
