# Dotfiles — xmb03

Миграция с Arch Linux на **NixOS**.  
Скопировано из `~/.config/` — для интеграции в NixOS flake/home-manager.

---

## Структура

```
dotfiles/
├── i3/                          # WM (config + user/ + system/ + scripts/)
│   ├── config                   # главный конфиг (include user/ + system/)
│   ├── user/                    # пользовательские настройки (autostart, binds, bar, monitor, settings)
│   ├── system/                  # системные настройки (autostart, binds, settings)
│   ├── scripts/rofi-wallpaper   # выбор обоев через rofi + feh
│   └── i3status-rs/config.toml  # status bar (используется bar.conf)
├── zathura/                     # PDF reader (wal-generated -> stylix)
├── kitty/                       # terminal (include wal -> stylix)
├── nvim/                        # LazyVim + neopywal
│   ├── init.lua                 # точка входа
│   ├── lua/config/              # lazy.lua, options.lua, keymaps.lua, autocmds.lua
│   ├── lua/plugins/             # pywal.lua (+ example.lua)
│   └── lazy-lock.json           # все плагины с коммитами
├── rofi/                        # app launcher (@import wal -> stylix)
├── gtk-3.0/                     # GTK3: font, theme, bookmarks
├── gtk-4.0/                     # GTK4: font, theme
├── fontconfig/                  # font aliases -> JetBrainsMono Nerd Font
├── redshift/                    # blue light filter
├── wal/                         # pywal templates + colorschemes (референс)
├── dconf/                       # gsettings dump
└── shell/                       # shell configs
    ├── bashrc                   # PATH, nvm, aliases
    ├── bash_profile             # source .bashrc
    ├── .zshrc                   # zsh: aliases, autosuggestions, syntax-highlighting
    ├── xprofile                 # touchpad settings
    ├── Xresources               # #include wal -> stylix
    └── fehbg                    # wallpaper script
```

---

## Пакеты (для home-manager)

### Системные

| Пакет | Назначение | Источник |
|-------|-----------|----------|
| `i3` | WM | `i3/config` |
| `i3status-rust` | status bar | `i3/user/bar.conf:9` |
| `rofi` | app launcher / clipboard / w-switcher | `i3/user/binds.conf:11-13` |
| `kitty` | terminal | — |
| `neovim` | editor | — |
| `zathura` | PDF viewer | — |
| `dunst` | notifications | `i3/user/autostart.conf:2` |
| `redshift` | blue light filter | `i3/user/autostart.conf:11` |
| `udiskie` | auto-mount USB | `i3/user/autostart.conf:14` |
| `greenclip` | clipboard manager | `i3/user/binds.conf:12` |
| `firefox` | browser | `i3/user/binds.conf:7` |
| `dex` | XDG autostart | `i3/system/autostart.conf:2` |
| `nm-applet` | network manager tray | `i3/system/autostart.conf:5` |
| `xss-lock` | suspend hook | `i3/user/autostart.conf:5` |
| `i3lock` | lock screen | `i3/user/autostart.conf:5` |
| `xrdb` | Xresources loader | `i3/user/autostart.conf:8` |
| `xset` | keyboard repeat | `i3/user/settings.conf:3` |
| `xrandr` | monitor mode/rate | `i3/user/monitor.conf:3` |
| `xdotool` | keyboard layout toggle | `i3/i3status-rs/config.toml:19` |
| `pulseaudio` / `pipewire-pulse` | volume via `pactl` | `i3/system/binds.conf:4-6` |
| `i3-sensible-terminal` | fallback terminal | `i3/system/binds.conf:10` |
| `i3-nagbar` | exit confirmation | `i3/system/binds.conf:69` |
| `feh` | wallpaper setter | `i3/scripts/rofi-wallpaper:16`, `shell/fehbg` |
| `pywal` | color scheme generator | `i3/scripts/rofi-wallpaper:12` (заменить на stylix) |
| `wal-telegram` | Telegram theming | `i3/scripts/rofi-wallpaper:13` (заменить на stylix) |

### Shell / Zsh

| Пакет | Назначение | Источник |
|-------|-----------|----------|
| `zsh` | shell | `shell/.zshrc` |
| `zsh-autosuggestions` | zsh plugin: автоподстановки | `shell/.zshrc:23` |
| `zsh-syntax-highlighting` | zsh plugin: подсветка синтаксиса | `shell/.zshrc:24` |
| `zsh-completions` | zsh completions | `shell/.zshrc` (fpath) |

### Шрифты

| Font | Где используется |
|------|-----------------|
| `JetBrains Mono` | `kitty/kitty.conf:1`, `gtk-3.0/settings.ini:2`, `gtk-4.0/settings.ini:2` |
| `JetBrainsMono Nerd Font` | `fontconfig/fonts.conf:7,12,17` |

---

## Neovim плагины (lazy.nvim)

Из `nvim/lazy-lock.json` (27 плагинов):

| Плагин | Назначение |
|--------|-----------|
| `LazyVim/LazyVim` | base distro |
| `folke/lazy.nvim` | plugin manager |
| `RedsXDD/neopywal.nvim` | **pywal colorscheme** → заменить на stylix/base16 |
| `blink.cmp` | completion |
| `bufferline.nvim` | tabs |
| `catppuccin` | fallback theme |
| `conform.nvim` | formatter |
| `flash.nvim` | navigation |
| `friendly-snippets` | snippets |
| `gitsigns.nvim` | git |
| `grug-far.nvim` | search-replace |
| `lazydev.nvim` | Lua LSP |
| `lualine.nvim` | statusline |
| `mason.nvim` + `mason-lspconfig.nvim` | LSP installer |
| `mini.ai`, `mini.icons`, `mini.pairs` | mini modules |
| `noice.nvim` + `nui.nvim` | UI |
| `nvim-lint` | linter |
| `nvim-lspconfig` | LSP |
| `nvim-treesitter` + `nvim-treesitter-textobjects` | syntax |
| `nvim-ts-autotag` | autotag |
| `persistence.nvim` | sessions |
| `plenary.nvim` | utility |
| `snacks.nvim` | animations |
| `todo-comments.nvim` | TODO |
| `tokyonight.nvim` | fallback |
| `trouble.nvim` | diagnostics |
| `ts-comments.nvim` | comments |
| `which-key.nvim` | keybinds |

---

## Зависимости от pywal (заменить на stylix/nix-colors)

| Файл | Строка | Импорт |
|------|--------|--------|
| `kitty/kitty.conf` | L19 | `include ~/.cache/wal/colors-kitty.conf` |
| `rofi/config.rasi` | L1 | `@import "~/.cache/wal/colors-rofi-dark.rasi"` |
| `shell/.Xresources` | L1 | `#include "/home/xmb03/.cache/wal/colors.Xresources"` |
| `i3/user/settings.conf` | L14-29 | `set_from_resource` (цвета из Xresources) |
| `i3/user/bar.conf` | L2-6 | `set_from_resource` (цвета из Xresources) |
| `nvim/lua/plugins/pywal.lua` | вся | `neopywal.nvim` |
| `zathura/zathurarc` | весь | сгенерирован pywal |

### Скрипт `i3/scripts/rofi-wallpaper`

Вызывает: `wal -i "$path"` + `wal-telegram --wal` + `feh --bg-fill "$path"`  
→ На NixOS заменить `wal` на stylix theme update или просто `feh` без генерации.

---

## Кастомный скрипт

| Скрипт | Назначение | Статус |
|--------|-----------|--------|
| `i3/scripts/rofi-wallpaper` | выбор обоев через rofi грид | ✅ скопирован |
| `i3/scripts/microphone.sh` | управление микрофоном | ❌ упомянут в README, не существует |

---

## Аппаратная привязка

- **Монитор:** `DP-0` 1920×1200 @ 165Hz (`i3/user/monitor.conf`)
- **Тачпад:** `FTCS1000:01 2808:0222 Touchpad` с natural scrolling (`shell/.xprofile`)
- **Шапка для обоих:** `gruvbox_image55.png` (`shell/.fehbg`)

---

## Быстрый старт на NixOS

1. Добавить `i3`, `rofi`, `kitty`, `zathura`, `dunst`, `redshift`, `udiskie`, `greenclip`, `feh`, `i3status-rust` в `environment.systemPackages` или `home.packages`
2. Каждый конфиг переписать вручную на Nix через HM-опции. НЕ `home.file`. НЕ `builtins.readFile`. Никаких исключений.
3. Настроить **stylix** или **nix-colors** — заменить все wal-импорты
4. Заменить `neopywal.nvim` на stylix/base16
5. Убрать `wal` / `wal-telegram` из `rofi-wallpaper`
6. Настроить `services.greenclip` в home-manager
7. Заменить pipewire на pulseaudio если нужно (или оставить pipewire)
8. **Zsh:** через `programs.zsh`, **не** через home.file. Все алиасы переписать под NixOS (up → nixos-rebuild switch)
