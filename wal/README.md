# wal

[pywal](https://github.com/dylanaraps/pywal) templates for desktop theming.

## Templates

| Template | Generates | Consumed by |
|---|---|---|
| `templates/zathurarc` | `~/.cache/wal/colors-zathurarc` | zathura (via include + symlink) |

The bootstrap script creates a symlink `~/.config/zathura/colors` → `~/.cache/wal/colors-zathurarc`, so zathura can `include "colors"` and stay in sync with the current wallpaper.
