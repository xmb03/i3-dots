# rofi

Application launcher, clipboard manager, and window switcher.

- `config.rasi` — imports `~/.cache/wal/colors-rofi-dark.rasi` for pywal theming
- Used in four modes:
  - `$mod+d` — `rofi -show drun` (app launcher)
  - `$mod+v` — `rofi -modi "clipboard:greenclip print" -show clipboard`
  - `$mod+Tab` — `rofi -show` (window switcher)
  - `$mod+r` — `powermenu.rasi` theme + `powermenu.sh` (Lock, Logout, Suspend, Hibernate, Reboot, Shutdown)
- `powermenu.rasi` — grid layout (3×2) with big filled squares, pywal colors, Nerd Font icons
