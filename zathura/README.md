# zathura

PDF viewer with pywal-driven dark theming.

- `zathurarc` — includes `~/.cache/wal/colors-zathurarc` via `include "colors"`
- Symlink `~/.config/zathura/colors` → `~/.cache/wal/colors-zathurarc` created by bootstrap
- Recolor enabled for dark-mode PDF viewing
- Colors are updated on every `wal -i` run

The pywal template is at `../wal/templates/zathurarc`.
