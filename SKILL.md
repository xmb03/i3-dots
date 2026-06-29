---
name: dotfiles-nixos
description: >-
  Перенос dotfiles с Arch Linux на NixOS/home-manager/stylix.
  Содержит полную карту конфигов (i3/kitty/nvim/rofi/gtk/zathura),
  списки пакетов, neovim плагинов, и конвертацию pywal→stylix.
  Использовать когда речь о dotfiles, NixOS, home-manager, flake, stylix,
  переносе конфигов, i3, rofi-wallpaper, neopywal.
license: MIT
compatibility: opencode
metadata:
  project: dotfiles-nixos
  source: arch
  target: nixos
---

# Миграция dotfiles → NixOS

> ⚠ **Дисклеймер:** промт строгий, никакой халтуры.
> Каждый файл из dotfiles/ → Nix. Все алиасы → NixOS.
> Git commit в конце обязателен.

## Карта проекта

```
~/.config/dotfiles/
├── i3/                          # WM
│   ├── config                   # главный (include user/ + system/)
│   ├── user/                    # настройки пользователя
│   │   ├── autostart.conf       # автозапуск (dunst, redshift, xss-lock, udiskie, rofi-wallpaper)
│   │   ├── bar.conf             # status bar (i3status-rs) + цвета
│   │   ├── binds.conf           # хоткеи (flameshot, rofi, firefox, wallpaper)
│   │   ├── monitor.conf         # DP-0 1920x1200 @ 165Hz
│   │   └── settings.conf        # цвета окон (set_from_resource), keyboard repeat
│   ├── system/                  # системные настройки
│   │   ├── autostart.conf       # dex, nm-applet
│   │   ├── binds.conf           # volume, focus, workspace, resize mode
│   │   └── settings.conf        # floating, workspaces
│   ├── scripts/rofi-wallpaper   # выбор обоев (wal + feh → переписать)
│   └── i3status-rs/config.toml  # статус-бар: клавиатура, звук, яркость, часы
├── zathura/                     # PDF (цвета от wal → stylix)
├── kitty/                       # терминал (include wal → stylix)
├── nvim/                        # LazyVim
│   ├── init.lua                 # точка входа
│   ├── lua/config/lazy.lua      # lazy.nvim bootstrap
│   ├── lua/config/options.lua   # опции
│   ├── lua/config/keymaps.lua   # хоткеи
│   ├── lua/config/autocmds.lua  # авто-команды
│   ├── lua/plugins/pywal.lua    # neopywal → stylix
│   └── lazy-lock.json           # 27 плагинов
├── rofi/                        # лаунчер (@import wal → stylix)
├── gtk-3.0/                     # GTK3 шрифт + тема
├── gtk-4.0/                     # GTK4 шрифт + тема
├── fontconfig/                  # font aliases → JetBrainsMono NF
├── redshift/                    # фильтр синего
├── wal/                         # pywal шаблоны (референс)
│   └── templates/zathurarc      # шаблон для zathura
├── dconf/                       # gsettings дамп
└── shell/
    ├── bashrc                   # PATH, nvm
    ├── bash_profile             # source .bashrc
    ├── .zshrc                   # zsh: aliases, autosuggestions, syntax-highlighting
    ├── xprofile                 # тачпад (→ NixOS libinput)
    ├── Xresources               # #include wal → stylix
    └── fehbg                    # обои
```

---

## Глобальные конфиги (без изменений, просто копировать)

Эти файлы — reference. Каждый переносится на Nix через HM-опции inline, без home.file:

| Путь в dotfiles | Назначение | HM-опция (inline) |
|----------------|-----------|-------------|
| `gtk-3.0/settings.ini` | GTK3 шрифт | `gtk.font.name` |
| `gtk-3.0/gtk.css` | GTK3 кастомный CSS | AI ищет WebSearch: home-manager gtk.css |
| `gtk-3.0/bookmarks` | закладки | `gtk.gtk3.bookmarks` |
| `gtk-4.0/settings.ini` | GTK4 шрифт | `gtk.font.name` |
| `gtk-4.0/gtk.css` | GTK4 кастомный CSS | AI ищет WebSearch: home-manager gtk.css |
| `fontconfig/fonts.conf` | aliases → JetBrains | `fonts.fontconfig` |
| `redshift/redshift.conf` | фильтр синего | `services.redshift.settings` |

---

## Конфиги с wal→stylix заменой

### 1. kitty/kitty.conf

```diff
- include ~/.cache/wal/colors-kitty.conf
+ # stylix управляет цветами через theme.base16Scheme
```

В stylix цвета приходят через `base16Scheme`. Для kitty не нужно include — stylix сам генерирует конфиг.

### 2. rofi/config.rasi

```diff
- @import "~/.cache/wal/colors-rofi-dark.rasi"
+ # цвета задаются через stylix или хардкод
```

Rofi не имеет прямого stylix модуля. Цвета нужно:
- либо захардкодить из текущей wal-схемы
- либо поставить `nix-colors` и генерировать rasi

### 3. shell/Xresources

```diff
- #include "/home/xmb03/.cache/wal/colors.Xresources"
+ # удалить — i3 цвета берёт от stylix
```

### 4. i3/user/settings.conf (set_from_resource)

```nix
# Вместо set_from_resource — stylix генерирует цвета напрямую
# Через модуль i3 в home-manager:
{
  xsession.windowManager.i3.config.colors = {
    focused = {
      border   = "#285577";
      background = "#285577";
      text     = "#ffffff";
      indicator = "#285577";
      childBorder = "#285577";
    };
    # ... остальные секции
  };
}
```

Конкретные цвета нужно взять из `set_from_resource` (сейчас привязаны к wal).

### 5. nvim/lua/plugins/pywal.lua

```diff
- return { "RedsXDD/neopywal.nvim" }
+ return {
+   "ntk148v/komau.vim",           # или любой stylix-совместимый
+   # Либо читать цвета из stylix через base16
+ }
```

### 6. shell/.zshrc

```diff
- source ~/.cache/wal/colors.sh
- cat ~/.cache/wal/sequences
+ # удалить — цвета от stylix base16
+ # Цвета zsh-syntax-highlighting захардкодить из gruvbox
```

Wal в zsh заменяется на stylix base16 scheme. Цвета для ZSH_HIGHLIGHT_STYLES и ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE захардкодить. PROMPT — захардкодить цвет.

---

## i3 — полная схема интеграции

i3 конфиг разбит на user/system. В home-manager — через `extraConfig` строкой вручную:

```nix
{
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = ''
      # i3 config — весь конфиг пишется вручную
      # Include директивы заменить на содержимое
      set $mod Mod4
      font pango:monospace 8
      # ... (весь конфиг одной строкой, без readFile)
    '';
  };
}
```

**НЕ идут в extraConfig (отдельные модули):**
- `i3/user/monitor.conf` → `modules/hardware/monitor.nix` (xrandrHeads)
- `i3/user/settings.conf` → `modules/wm/i3-settings.nix` (xset) + stylix (set_from_resource)

builtins.readFile НЕ ИСПОЛЬЗОВАТЬ.
i3status-rs: AI ищет WebSearch: "home-manager i3status-rust config".

---

## rofi-wallpaper (переписать без wal)

```bash
#!/bin/bash
# Переписан без pywal для NixOS

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/current_wallpaper"

apply_wallpaper() {
  local path="$1"
  feh --bg-fill "$path"
}

if [ "$1" == "--reset" ]; then
  if [ -f "$CACHE_FILE" ]; then
    SAVED_WALL=$(cat "$CACHE_FILE")
    apply_wallpaper "$SAVED_WALL"
    exit 0
  else
    echo "No cached wallpaper found."
    exit 1
  fi
fi

if [ ! -d "$WALL_DIR" ]; then
  notify-send "Error" "Directory $WALL_DIR not found."
  exit 1
fi

ROFI_DATA=""
for pic in "$WALL_DIR"/*; do
  if [ -f "$pic" ]; then
    filename=$(basename "$pic")
    ROFI_DATA+="${filename}\0icon\x1f${pic}\n"
  fi
done

CHOICE=$(echo -en "$ROFI_DATA" | rofi -dmenu -i -p "Wallpaper" \
  -show-icons -theme-str '
        listview {
            columns: 3;
            lines: 3;
            cycle: true;
        }
        element {
            orientation: vertical;
            padding: 10px;
        }
        element-icon {
            size: 8em;
        }
        element-text {
            horizontal-align: 0.5;
        }
    ')

if [ -n "$CHOICE" ]; then
  FULL_PATH="$WALL_DIR/$CHOICE"
  echo "$FULL_PATH" >"$CACHE_FILE"
  apply_wallpaper "$FULL_PATH"
fi
```

Изменения:
- убраны `wal -i`
- убраны `wal-telegram --wal`
- сам `feh --bg-fill` остался
- Скрипт переписать на Nix (programs., systemd.user.services, i3 bindsym exec). AI ищет WebSearch.

---

## Neovim (AI решает LazyVim)

```nix
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # AI ищет через WebSearch как подключить LazyVim на NixOS
    # builtins.readFile НЕ ИСПОЛЬЗОВАТЬ
    extraLuaConfig = ''
      -- сюда пишется lua-конфиг вручную
    '';
    extraPackages = with pkgs; [
      lua-language-server
      typescript-language-server
      stylua
    ];
  };
}
```

Плагин `neopywal` заменить на тему от stylix (catppuccin, tokyonight) — не включать.

---

## System packages (home.packages)

```nix
home.packages = with pkgs; [
  # WM утилиты
  i3status-rust        # статус-бар
  rofi                 # лаунчер
  rofi-calc            # калькулятор в rofi
  feh                  # обои
  dunst                # уведомления
  xss-lock             # блокировка при suspend
  i3lock               # экран блокировки
  xdotool              # переключение раскладки
  xclip                # буфер обмена CLI

  # Мультимедиа
  redshift             # фильтр синего
  pulsemixer           # управление звуком (альтернатива pactl)
  playerctl            # медиа-клавиши

  # Система
  udiskie              # авто-монтирование USB
  dex                  # XDG autostart
  greenclip            # менеджер буфера обмена
  notify-desktop       # notify-send

  # Терминал
  kitty                # терминал
  neovim               # редактор
  zathura              # PDF

  # Шрифты
  jetbrains-mono
  nerd-fonts.jetbrains-mono

  # Shell
  zsh                  # shell
  zsh-autosuggestions  # zsh plugin: автоподстановки
  zsh-syntax-highlighting # zsh plugin: подсветка синтаксиса
  zsh-completions      # zsh plugin: расширенные комплишеншены

  # Прочее
  file                 # file command
  tree                 # tree
];
```

---

## Shell конфиги

### bash

```nix
programs.bash = {
  enable = true;
  bashrcExtra = ''
    # PATH, алиасы из dotfiles/shell/bashrc, без lmstudio/open code/nvm
    export PATH="$HOME/.npm-global/bin:$PATH"
    alias up="sudo nixos-rebuild switch"
    alias c="clear"
    alias l="ls -lh --color=auto"
    # ...
  '';
};
```

НЕ использовать `home.file` для bash.
Перед вставкой в bashrcExtra почистить от:
- `~/.lmstudio/bin` (удалить — LM Studio не нужен)
- `~/.opencode/bin` (заменить на opencode в systemPackages)
- `NVM_DIR` (nvm через home-manager: `programs.nvm.enable = true`)

### zsh — через programs.zsh (чистый Nix, без home.file)

```nix
programs.zsh = {
  enable = true;
  enableAutosuggestions = true;
  enableSyntaxHighlighting = true;
  shellAliases = {
    up = "sudo nixos-rebuild switch";
    n = "nvim";
    c = "clear";
    cat = "bat";
    l = "ls -lh --color=auto";
    la = "ls -lha --color=auto";
    .. = "cd ..";
    ... = "cd ../..";
    f = "fastfetch";
    mem = "free -h";
    disk = "df -h";
    top = "btop";
  };
  envExtra = ''
    fpath+=(${pkgs.zsh-completions}/share/zsh-completions)
    autoload -Uz compinit && compinit
  '';
  # Aliases из dotfiles/shell/.zshrc полностью переписаны выше
  # Wal-строки не копировать — stylix base16 вместо них
};
```

**Пакеты:** `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`

**Алиас `up`:** `sudo pacman -Syu` → `sudo nixos-rebuild switch`

### xprofile (тачпад) — через NixOS libinput

```nix
# В configuration.nix или modules:
services.xserver.libinput = {
  enable = true;
  touchpad = {
    naturalScrolling = true;
    accelProfile = "adaptive";
    accelSpeed = "-0.39";
  };
};
```

### fehbg (обои)

Не home.file. Добавить в i3 extraConfig или startup:

```nix
xsession.windowManager.i3.config.startup = [
  { command = "feh --bg-fill /home/xmb03/Pictures/Wallpapers/gruvbox_image55.png"; }
];
```

### Xresources

**ВАЖНО:** НЕ СТАВИТЬ `home.file.".Xresources"` — stylix сам генерирует `.Xresources` через `stylix.targets.i3.enable = true`. Если home-manager перезапишет .Xresources, `set_from_resource` в i3 не найдёт цвета.

---

## dconf (gsettings)

```nix
dconf.settings = {
  "org/gnome/desktop/interface" = {
    font-name = "JetBrains Mono 10";
    monospace-font-name = "JetBrainsMono Nerd Font Mono 10";
  };
  # Остальное из дампа:
  # dconf dump / > dconf-settings.conf
};
```

---

## Аппаратная привязка (NixOS)

```nix
# Монитор — в конфиге i3 или через xrandr service
# Тачпад — libinput (см. выше)
# Обои — feh + rofi-wallpaper
```

---

## stylix настройка

```nix
{ pkgs, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = null; # используем base16Scheme, а не картинку

    fonts = {
      monospace = {
        name = "JetBrainsMono Nerd Font Mono";
        package = pkgs.jetbrains-mono;
      };
      sansSerif = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.jetbrains-mono;
      };
      serif = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.jetbrains-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji;
      };
    };

    opacity = {
      applications = 0.95;
      terminal = 0.90;
      desktop = 1.0;
      popups = 0.95;
    };

    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
```

Для i3 stylix пробрасывает цвета через Xresources. Нужно включить:

```nix
stylix.targets.i3.enable = true;
# stylix.targets.kitty.enable = true;
# stylix.targets.gtk.enable = true;
```

---

## home-manager flake шаблон

```nix
# flake.nix
{
  description = "NixOS + home-manager dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
  };

  outputs = { nixpkgs, home-manager, stylix, ... }: {
    homeConfigurations."xmb03" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        stylix.homeManagerModules.stylix
        ./home.nix
      ];
    };
  };
}
```

## Check-лист после nixos-rebuild

- [ ] i3 запускается, хоткеи работают
- [ ] kitty открывается, цвета правильные
- [ ] rofi открывается ($mod+d), цвета правильные
- [ ] zathura открывает PDF
- [ ] nvim работает, плагины загружены
- [ ] тачпад: natural scrolling
- [ ] монитор: 1920x1200 @ 165Hz
- [ ] обои установлены (feh)
- [ ] звук: клавиши громкости работают
- [ ] скриншоты (Print, $mod+Shift+s)
- [ ] уведомления (dunst)
- [ ] буфер обмена (greenclip)
- [ ] redshift работает
- [ ] USB автомонтируется (udiskie)
- [ ] nm-applet в трее

---

## Исключено (не копировать)

| Директория | Причина |
|-----------|---------|
| `i3nix/` | старый nix конфиг, не нужен |
| `LM Studio/`, `LM-Studio/`, `.lmstudio/` | LLM софт, не для NixOS |
| `VirtualBox/`, `VirtualBox VMs/` | VM, не для dotfiles |
| `Vencord/`, `vesktop/`, `legcord/`, `equibop/`, `Equicord/` | Discord клиенты, только темы |
| `obsidian/` | Chrome-стор, не конфиг |
| `mozilla/firefox/` | профиль FF |
| `opencode/` | привязан к LM Studio |
| `qBittorrent/` | торренты |
| `tgwsproxy/` | специфичный прокси |
| `ranger/`, `mpv/` | пустые |
| `pulse/` | только cookie |
| `xfce4/` | незначимые настройки |
| `i3status/` | используется i3status-rust, а не i3status |
