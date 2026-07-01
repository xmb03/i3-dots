# rofi

Application launcher, clipboard manager, and window switcher.

- `config.rasi` — imports `~/.cache/wal/colors-rofi-dark.rasi` for pywal theming
- Used in four modes:
  - `$mod+d` — `rofi -show drun` (app launcher)
  - `$mod+v` — `rofi -modi "clipboard:greenclip print" -show clipboard`
  - `$mod+Tab` — `rofi -show` (window switcher)
  - `$mod+r` — `powermenu.rasi` theme + `powermenu.sh` (Lock, Logout, Suspend, Hibernate, Reboot, Shutdown)
- `powermenu.rasi` — grid layout (3×2) with big filled squares, pywal colors, Nerd Font icons
- `nowplaying/` — rofi-music-control: album art, track info, playback controls (prev/play-pause/next)
  - `$mod+m` or click music block in i3status-rust bar
  - Shows album art + track title/artist + control buttons
  - Pywal-themed, zero rounded corners, matches powermenu style
