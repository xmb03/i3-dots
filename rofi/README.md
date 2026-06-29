# rofi

Application launcher, clipboard manager, and window switcher.

- `config.rasi` — imports `~/.cache/wal/colors-rofi-dark.rasi` for pywal theming
- Used in three modes:
  - `$mod+d` — `rofi -show drun` (app launcher)
  - `$mod+v` — `rofi -modi "clipboard:greenclip print" -show clipboard`
  - `$mod+Tab` — `rofi -show` (window switcher)
