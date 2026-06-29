# NIXOS-PROMT.md — Инструкция для AI по переносу dotfiles на NixOS

**Версия:** 2.0
**Автор:** xmb03
**Тип:** Промт для нейросети (не opencode skill)

---

## ДИСКЛЕЙМЕР ДЛЯ AI

**Этот промт строго обязателен к исполнению. Халтура запрещена.**

1. **Не сокращать.** Каждый пункт из этого промта должен быть выполнен.
   Если тебе кажется что пункт неважен — ты ошибаешься.

2. **Не угадывать.** Если что-то неясно — пиши мне (пользователю) вопросы.
   Не додумывай пути, не делай предположений.

3. **Не предлагать альтернативы.** Промт описывает точный план.
   Следуй ему буквально. Если видишь проблему — спроси, не меняй план сам.

4. **Проверять себя.** После каждого модуля мысленно прогоняй `nixos-rebuild test`.
   Если сомневаешься в синтаксисе — перепроверь через поиск.

5. **Никаких home.file.** Каждый конфиг переписывается на Nix. Полностью. Без исключений.
   Нет HM-опции? Ищи через WebSearch как это сделать на Nix. Не предлагай home.file.

6. **Git — обязательно.** В конце сессии сделать commit + push на GitHub.
   Без этого задача не считается выполненной.

Нарушение этих правил = переделывать всё заново.

---

## 0. ПРАВИЛА РАБОТЫ ДЛЯ AI

```
1. Создать новую папку (например ~/nixos-config/).
   Старую папку ~/nixdot/ удалить.
   (flake.nix, configuration.nix, home.nix, modules/*)

2. Дважды проверять синтаксис Nix через WebSearch перед написанием.
   Nix строгий — невалидный файл роняет сборку.
   Особенно проверять: пути, кавычки, точки с запятой, импорты.

3. dotfiles/ НЕ КОПИРОВАТЬ в новую папку. NOT home.file — только Nix options.
   Каждый конфиг переписывается на Nix через home-manager опции.

4. home.nix НЕ ДОЛЖЕН быть плоским — импортирует модули из ./modules/.

5. Каждый модуль — отдельный .nix файл, который можно включить/отключить.

6. Перед сдачей: мысленно прогнать nixos-rebuild test в голове.
   Если хоть одна строчка вызывает сомнение — перепроверить через WebSearch.

7. Не писать готовый flake.nix целиком — описать структуру.
   AI сам должен написать код под эту структуру.

8. КАЖДЫЙ файл из dotfiles/ перенести на Nix через home-manager.
   Структура dotfiles/ СОХРАНЯЕТСЯ как reference (под Arch).

   ❌ builtins.readFile — ЗАПРЕЩЁН. Каждый файл переписывается вручную на Nix.

   ❌ home.file — ЗАПРЕЩЁН. Полностью. Никаких исключений.

   Архитектура — каждый подконфиг → отдельный .nix модуль:
   - i3/user/monitor.conf → modules/hardware/monitor.nix (NixOS xrandrHeads)
   - i3/user/settings.conf → stylix + modules/wm/i3-settings.nix
   - i3/user/bar.conf → stylix цвета + extraConfig
   - i3/user/autostart.conf → i3 extraConfig (ручной перенос)
   - i3/user/binds.conf → i3 extraConfig (ручной перенос)
   - i3/system/* → i3 extraConfig (ручной перенос)
   - kitty/kitty.conf → programs.kitty.settings (ручной перенос)
   - shell/.zshrc → programs.zsh.initExtra (ручной перенос, без readFile)
   - shell/bashrc → programs.bash.bashrcExtra (ручной перенос, без readFile)
   - nvim/ → AI сам решает как подключить LazyVim на NixOS (WebSearch)
   - gtk-3.0/settings.ini → gtk.font + gtk.theme
   - gtk-3.0/bookmarks → gtk.gtk3.bookmarks
   - redshift/redshift.conf → services.redshift.settings
   - shell/.fehbg → i3 startup
   - shell/Xresources → stylix.targets.i3 (не трогать)

9. Все алиасы и команды переписать под NixOS:
   - pacman -Syu → nixos-rebuild switch
   - pacman -S → nix-shell -p / home.packages
   - systemctl → systemd.user / systemd.services
   - yaourt/yay → nix-shell / nixpkgs

10. В конце сессии — git snapshot:
    - Создать папку (например ~/nixos-config/) — НЕ nixdot, nixdot удалить
    - git init && git add -A
    - git commit -m "feat: full NixOS config from dotfiles"
    - GitHub CLI: gh repo create <user>/nixos-config --public --push
    - git push -u origin main
```

---

## 1. КОНТЕКСТ

- **Пользователь:** xmb03
- **Откуда:** Arch Linux (i3wm, kitty, nvim, pywal)
- **Куда:** NixOS + home-manager + stylix/nix-colors
- **dotfiles:** `/home/xmb03/.config/dotfiles/` — 43 файла, 12 директорий
- **Проект:** AI создаёт НОВУЮ папку (например `~/nixos-config/`).
  Папку `~/nixdot/` удалить — она устарела.
- **Два режима:**
  1. `nixos-rebuild` — полная система (NixOS + HM + stylix)
  2. `home-manager switch` — только пользователь (если NixOS уже стоит)

- **Цель AI:**
  - Спроектировать модульную структуру НОВОЙ папки (напр. ~/nixos-config/)
  - Каждый модуль описывает одну программу или сервис
  - Учесть замену pywal на stylix во всех конфигах
  - Не копировать dotfiles, ссылаться на них

---

## 2. СТРУКТУРА dotfiles (ЧТО ЕСТЬ НА ДИСКЕ)

```
~/.config/dotfiles/           # 47 файлов — читать как reference для переноса в Nix
│
├── i3/                       # WM — главный конфиг
│   ├── config                # точка входа (include user/ + system/)
│   ├── user/                 # autostart.conf, bar.conf, binds.conf,
│   │                           monitor.conf, settings.conf
│   ├── system/               # autostart.conf, binds.conf, settings.conf
│   ├── scripts/
│   │   └── rofi-wallpaper    # выбор обоев (убрать wal)
│   └── i3status-rs/
│       └── config.toml       # статус-бар
│
├── zathura/                  # PDF (цвета wal → stylix или хардкод)
│   └── zathurarc
│
├── kitty/                    # терминал (include wal → stylix)
│   └── kitty.conf
│
├── nvim/                     # LazyVim (neopywal → base16)
│   ├── init.lua
│   ├── lua/config/           # lazy.lua, options.lua, keymaps.lua, autocmds.lua
│   ├── lua/plugins/          # pywal.lua, example.lua
│   └── lazy-lock.json        # 27 плагинов
│
├── rofi/                     # лаунчер (@import wal → хардкод)
│   └── config.rasi
│
├── gtk-3.0/                  # GTK3 (шрифт + стили + bookmarks)
│   ├── settings.ini
│   ├── gtk.css
│   └── bookmarks
│
├── gtk-4.0/                  # GTK4 (шрифт + стили)
│   ├── settings.ini
│   └── gtk.css
│
├── fontconfig/               # aliases → JetBrainsMono NF
│   └── fonts.conf
│
├── redshift/                 # фильтр синего
│   └── redshift.conf
│
├── wal/                      # pywal шаблоны (референс, не использовать)
│   └── templates/zathurarc
│
├── dconf/                    # gsettings (бинарный дамп)
│   └── user
│
├── shell/                    # shell конфиги
│   ├── bashrc
│   ├── bash_profile
│   ├── .zshrc                # zsh: aliases, autosuggestions, syntax-highlighting
│   ├── xprofile
│   ├── Xresources
│   └── fehbg
│
└── README.md                 # документация
```

---

## 3. МОДУЛЬНАЯ СТРУКТУРА ~/nixos-config/ (ЧТО СОЗДАТЬ)

> **ВАЖНО:** Каждый модуль — ЧИСТЫЙ NIX. Структура dotfiles/ сохраняется.
> ❌ builtins.readFile — запрещён. Всё пишется вручную.
> ❌ home.file — запрещён ПОЛНОСТЬЮ. Без исключений.

```
~/nixos-config/                # НОВЫЙ проект — nixdot удалить
│
├── flake.nix                  # входная точка (inputs + outputs)
├── configuration.nix          # NixOS система (импортирует home-manager)
├── home.nix                   # home-manager (импортирует ./modules/*)
│
├── modules/                   # Nix-модули — каждый за свою программу
│   ├── wm/
│   │   ├── i3.nix             # i3 + extraConfig (autostart, binds, bar, system)
│   │   └── i3-settings.nix    # цвета, keyboard repeat (set_from_resource → stylix)
│   ├── theme/
│   │   └── stylix.nix         # stylix: цвета, шрифты, курсор, targets
│   ├── editor/
│   │   └── nvim.nix           # neovim + lazy-lock
│   ├── term/
│   │   └── kitty.nix          # kitty
│   ├── shell/
│   │   ├── bash.nix           # bash алиасы + env
│   │   └── zsh.nix            # zsh алиасы + автодополнение
│   ├── apps/
│   │   ├── rofi.nix           # лаунчер
│   │   └── zathura.nix        # PDF
│   ├── gtk/
│   │   └── gtk.nix            # GTK3 + fontconfig
│   ├── services/
│   │   ├── redshift.nix       # фильтр синего
│   │   ├── greenclip.nix      # буфер обмена
│   │   └── udiskie.nix        # авто-монтирование
│   ├── hardware/
│   │   ├── monitor.nix        # DP-0 1920×1200 @ 165Hz
│   │   └── touchpad.nix       # libinput тачпад
│   └── scripts/
│       └── rofi-wallpaper.nix # кастомный скрипт
│
└── wallpaper/                  # обои (если понадобятся)
    └── gruvbox_image55.png
```

> Модули НЕ читают dotfiles. Они самодостаточны — каждый конфиг переписан на Nix вручную.

### Как home.nix подключает модули

```nix
# ~/nixos-config/home.nix — НЕ вставлять готовый код, а написать по образу:
{ pkgs, config, lib, ... }:

{
  imports = [
    ./modules/wm/i3.nix
    ./modules/term/kitty.nix
    ./modules/editor/nvim.nix
    ./modules/theme/stylix.nix
    ./modules/apps/rofi.nix
    ./modules/apps/zathura.nix
    ./modules/gtk/gtk.nix
    ./modules/services/redshift.nix
    ./modules/services/greenclip.nix
    ./modules/services/udiskie.nix
    ./modules/hardware/monitor.nix
    ./modules/hardware/touchpad.nix
    ./modules/scripts/rofi-wallpaper.nix
  ];
}
```

---

## 4. РАЗБОР ПО МОДУЛЯМ

### 4.1. Модуль wm/i3.nix (остаётся в extraConfig)

**i3/config + user/* + system/* — переписать вручную в extraConfig.**

Что идёт в extraConfig:
- `i3/config` — весь конфиг (include директивы заменить на их содержимое)
- `i3/user/autostart.conf` — автозапуск (dunst, xss-lock, udiskie)
- `i3/user/bar.conf` — статус-бар
- `i3/user/binds.conf` — хоткеи
- `i3/system/autostart.conf` — dex, nm-applet
- `i3/system/binds.conf` — volume, focus, workspace
- `i3/system/settings.conf` — floating, workspaces

**Какие файлы НЕ идут в extraConfig (отдельные модули):**
- `i3/user/monitor.conf` → `modules/hardware/monitor.nix` (xrandrHeads)
- `i3/user/settings.conf` → `modules/wm/i3-settings.nix` (xset) + stylix (set_from_resource)

**Что сделать:**
- `xsession.windowManager.i3.enable = true`
- `xsession.windowManager.i3.extraConfig = ''...''` — весь конфиг пишется вручную внутри строки.
  Include-директивы из config (`include user/`, `include system/`) заменить на содержимое.
  builtins.readFile НЕ ИСПОЛЬЗОВАТЬ.
- НЕ ставить `home.file."...i3"`.

**i3status-rs:**
- AI ищет WebSearch: "home-manager i3status-rust config".

**Пакеты:** `i3status-rust`

---

### 4.2. Модуль theme/stylix.nix

**Какие файлы из dotfiles использует:**
- `/home/xmb03/.config/dotfiles/kitty/kitty.conf` (нужно убрать include wal)
- `/home/xmb03/.config/dotfiles/rofi/config.rasi` (нужно убрать @import wal)
- `/home/xmb03/.config/dotfiles/shell/Xresources` (нужно убрать #include wal)
- `/home/xmb03/.config/dotfiles/zathura/zathurarc` (цвета от wal → хардкод или stylix)
- `/home/xmb03/.config/dotfiles/nvim/lua/plugins/pywal.lua` (neopywal → base16)

**Что сделать:**
- `stylix.enable = true`
- `stylix.base16Scheme` — задать gruvbox-dark-hard
- `stylix.targets.i3.enable = true` — stylix сгенерирует .Xresources
- `stylix.targets.kitty.enable = true` — stylix сгенерирует colors-kitty.conf
- `stylix.targets.gtk.enable = true` — stylix настроит GTK

**Важно:**
- НЕ ставить `home.file.".Xresources"` — stylix сам его создаёт
- Из `kitty/kitty.conf` удалить `include ~/.cache/wal/colors-kitty.conf`
- Из `rofi/config.rasi` удалить `@import "~/.cache/wal/colors-rofi-dark.rasi"` и захардкодить цвета
- Из `zathura/zathurarc` захардкодить цвета (stylix пока не умеет генерировать zathura)
- `neopywal.nvim` заменить на base16-nvim (комментарий в модуле editor/nvim.nix)

---

### 4.3. Модуль editor/nvim.nix

**Файлы из dotfiles (reference):**
- `/home/xmb03/.config/dotfiles/nvim/init.lua`
- `/home/xmb03/.config/dotfiles/nvim/lua/config/lazy.lua`
- `/home/xmb03/.config/dotfiles/nvim/lua/config/options.lua`
- `/home/xmb03/.config/dotfiles/nvim/lua/config/keymaps.lua`
- `/home/xmb03/.config/dotfiles/nvim/lua/config/autocmds.lua`
- `/home/xmb03/.config/dotfiles/nvim/lua/plugins/pywal.lua`
- `/home/xmb03/.config/dotfiles/nvim/lazy-lock.json`

**Что сделать:**
- `programs.neovim.enable = true`
- **AI ищет через WebSearch как подключить LazyVim на NixOS/home-manager.**
  builtins.readFile НЕ ИСПОЛЬЗОВАТЬ.
  neopywal НЕ включать — заменить на catppuccin (уже в плагинах).
- `programs.neovim.extraPackages` — lua-language-server, stylua, typescript-language-server

---

### 4.4. Модуль term/kitty.nix

**Файлы из dotfiles (reference):**
- `/home/xmb03/.config/dotfiles/kitty/kitty.conf`

**Что сделать (inline, без home.file):**
- `programs.kitty.enable = true`
- `programs.kitty.settings = { ... }` — каждую опцию из kitty.conf переписать как ключ=значение:
  ```nix
  programs.kitty.settings = {
    font_family = "JetBrainsMono Nerd Font Mono";
    font_size = "10";
    background_opacity = "0.90";
    scrollback_lines = "10000";
    tab_bar_edge = "bottom";
    # и т.д.
  };
  ```
- Удалить из kitty.conf при переносе: `include ~/.cache/wal/colors-kitty.conf`
  (stylix.targets.kitty.enable = true сам генерирует цвета)
- НЕ использовать `home.file` для kitty.
- Если опция из kitty.conf не маппится на `settings` (например `include`) — пропустить.

**Пакеты:** `kitty`

---

### 4.5. Модуль shell/

#### 4.5.1. bash

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/shell/bashrc`
- `/home/xmb03/.config/dotfiles/shell/bash_profile`

**Что сделать:**
- `programs.bash.enable = true`
- Алиасы и PATH из bashrc — в `programs.bash.shellInit` и `programs.bash.bashrcExtra`
- Удалить lmstudio/nvm/open code строки при переносе
- **Алиас up → nixos-rebuild switch**

#### 4.5.2. zsh

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/shell/.zshrc`

**Что сделать (ручной перенос, без readFile):**
- `programs.zsh.enable = true`
- `programs.zsh.enableAutosuggestions = true`
- `programs.zsh.enableSyntaxHighlighting = true`
- Алиасы из .zshrc переписать в `programs.zsh.shellAliases`:
  - `n = "nvim"`, `c = "clear"`, `cat = "bat"`, `l = "ls -lh --color=auto"`, `.. = "cd .."` и т.д.
  - **up (pacman) → sudo nixos-rebuild switch**
  - **top → btop**
- `programs.zsh.envExtra` — fpath для zsh-completions
- `programs.zsh.initExtra` — содержимое .zshrc без wal-строк:
  - удалить `source ~/.cache/wal/colors.sh`
  - удалить `cat ~/.cache/wal/sequences`
  - Цвета ZSH_HIGHLIGHT_STYLES захардкодить из gruvbox
- **Пакеты:** zsh, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions

#### 4.5.3. fehbg (обои)

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/shell/fehbg`

**Что сделать:**
- Не home.file. Добавить `exec_always feh --bg-fill ...` в i3 extraConfig
- Либо через `systemd.user.services` или `xsession.windowManager.i3.config.startup`

#### 4.5.4. Xresources

**НЕ включать** — stylix.targets.i3.enable = true сам генерирует .Xresources.

#### 4.5.5. xprofile

**НЕ включать** — перенесено в hardware/touchpad.nix (libinput).

---

### 4.6. Модуль apps/rofi.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/rofi/config.rasi`

**Что сделать:**
- `programs.rofi.enable = true`
- Тему rofi переписать на Nix. AI ищет WebSearch: "home-manager rofi theme config nix".
  Цвета взять из stylix base16 (gruvbox-dark-hard).

**Пакеты:** `rofi`, `rofi-calc`

---

### 4.7. Модуль apps/zathura.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/zathura/zathurarc`

**Что сделать:**
- `programs.zathura.enable = true`
- Конфиг zathura переписать на Nix. AI ищет WebSearch: "home-manager zathura config nix".
  Цвета захардкодить из gruvbox base16.

**Пакеты:** `zathura`

---

### 4.8. Модуль gtk/gtk.nix

**Файлы из dotfiles (reference):**
- `/home/xmb03/.config/dotfiles/gtk-3.0/settings.ini`
- `/home/xmb03/.config/dotfiles/gtk-3.0/gtk.css`
- `/home/xmb03/.config/dotfiles/gtk-3.0/bookmarks`
- `/home/xmb03/.config/dotfiles/gtk-4.0/settings.ini`
- `/home/xmb03/.config/dotfiles/gtk-4.0/gtk.css`
- `/home/xmb03/.config/dotfiles/fontconfig/fonts.conf`

**Что сделать (всё inline, без home.file):**

GTK настройки:
- `gtk.enable = true`
- `gtk.font.name = "JetBrains Mono"`
- `gtk.font.size = 10`
- `gtk.gtk3.bookmarks` — закладки из gtk-3.0/bookmarks

GTK.css:
- AI ищет WebSearch: "home-manager gtk.css nix stylix custom css"
- Вариант: `dconf.settings."org/gnome/desktop/interface"` или inline через stylix

Fontconfig:
- `fonts.fontconfig.enable = true`
- `fonts.fontconfig.defaultFonts.monospace = ["JetBrainsMono Nerd Font Mono"]`
- `fonts.fontconfig.defaultFonts.sans-serif = ["JetBrainsMono Nerd Font"]`

**Пакеты:** `jetbrains-mono`, `nerd-fonts.jetbrains-mono`, `papirus-icon-theme`

---

### 4.9. Модуль services/redshift.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/redshift/redshift.conf`

**Что сделать:**
- `services.redshift.enable = true`
- `services.redshift.latitude / longitude` — обязательно, без них не запустится
- `services.redshift.temperature.day = 6500`, `night = 3500`
- `services.redshift.settings.redshift."dusk-time" = "20:00"`
- `services.redshift.settings.redshift."dawn-time" = "07:00"`
- `services.redshift.settings.redshift.fade = 1`

--- 

### 4.10. Модуль services/greenclip.nix

**Файлы из dotfiles:** нет (файл greenclip.toml не копировался)

**Что сделать:**
- `services.greenclip.enable = true`
- `services.greenclip.settings` — задать inline:
  - `enable_image_support = true`
  - `max_history_length = 50`
  - `trim_space_from_selection = true`

---

### 4.11. Модуль services/udiskie.nix

**Файлы из dotfiles:** нет

**Что сделать:**
- `services.udiskie.enable = true`
- Пакет: `udiskie`

---

### 4.12. Модуль hardware/monitor.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/i3/user/monitor.conf` (информационно)

**Что сделать:**
Монитор DP-0, 1920×1200 @ 165Hz.

Через NixOS — `services.xserver.xrandrHeads`:
```nix
services.xserver.xrandrHeads = [
  { output = "DP-0"; primary = true; monitorConfig = "1920x1200_165.00"; }
];
```

---

### 4.13. Модуль hardware/touchpad.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/shell/xprofile` (информационно)

**Что сделать:**
- `services.xserver.libinput.enable = true`
- `services.xserver.libinput.touchpad.naturalScrolling = true`
- `services.xserver.libinput.touchpad.accelProfile = "adaptive"`
- `services.xserver.libinput.touchpad.disableWhileTyping = true`
- Тачпад: `FTCS1000:01 2808:0222`
- Accel speed: -0.39

Это NixOS-модуль (в `configuration.nix` через imports, не в home.nix).

---

### 4.14. Модуль scripts/rofi-wallpaper.nix

**Файлы из dotfiles:**
- `/home/xmb03/.config/dotfiles/i3/scripts/rofi-wallpaper`

**Что сделать:**
- Скрипт переписать на Nix. AI ищет WebSearch: "home-manager custom script nix executable".
- Варианты: `programs..`, `systemd.user.services`, i3 `bindsym exec` через extraConfig.
- В скрипте убраны вызовы `wal` и `wal-telegram`.

**Пакеты:** `feh`, `rofi`, `libnotify`

---

## 5. ПАКЕТЫ ПО МОДУЛЯМ

```
Модуль                  Пакеты
───                     ─────
wm/i3.nix               i3status-rust
theme/stylix.nix        (stylix — внешний input, не пакет)
editor/nvim.nix         neovim, lua-language-server, stylua
term/kitty.nix          kitty
apps/rofi.nix           rofi, rofi-calc
apps/zathura.nix        zathura
gtk/gtk.nix             jetbrains-mono, nerd-fonts.jetbrains-mono,
                        papirus-icon-theme
shell/bash.nix          (пакетов нет — programs.bash)
shell/zsh.nix           zsh, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions
services/redshift.nix   redshift
services/greenclip.nix  greenclip
services/udiskie.nix    udiskie
hardware/monitor.nix    (только xrandr — уже в i3)
hardware/touchpad.nix   (libinput — встроен в NixOS)
scripts/rofi-wallpaper  feh, libnotify
```

Дополнительно (нужны для работы i3):
```
i3 (xsession.windowManager.i3), dunst (уведомления),
xss-lock + i3lock (блокировка), xdotool (раскладка),
dex (XDG autostart), networkmanagerapplet (nm-applet),
pulsemixer/playerctl (звук)
```

---

## 6. WAL → STYLIX — ЧТО МЕНЯТЬ (ОПИСАНИЕ)

| Где | Что было | Что стало | Тип |
|-----|----------|-----------|-----|
| kitty/kitty.conf | `include ~/.cache/wal/colors-kitty.conf` | `stylix.targets.kitty.enable = true` | stylix сам |
| rofi/config.rasi | `@import "~/.cache/wal/colors-rofi-dark.rasi"` | хардкод hex-цветов в rasi | ручная замена |
| shell/Xresources | `#include "/home/.../colors.Xresources"` | `stylix.targets.i3.enable = true` | stylix сам |
| i3/settings.conf | `set_from_resource` цвета | хардкод или stylix через Xresources | stylix сам |
| i3/bar.conf | `set_from_resource` цвета | хардкод или stylix через Xresources | stylix сам |
| nvim/plugins/pywal.lua | `neopywal` (читает wal cache) | `base16-nvim` или `catppuccin` | ручная замена |
| zathura/zathurarc | сгенерирован pywal | захардкодить цвета из файла | ручная замена |
| shell/.zshrc | `source ~/.cache/wal/colors.sh` + `cat ~/.cache/wal/sequences` | удалить — цвета через stylix base16 | ручная замена |

**Порядок действий:**
1. Настроить stylix (targets i3, kitty, gtk)
2. Изменить kitty.conf — удалить include (stylix сгенерирует сам)
3. Переписать rofi/config.rasi — хардкод цветов
4. Переписать nvim/pywal.lua — другая тема
5. Захардкодить zathurarc (цвета из текущего файла)
6. .Xresources не трогать — stylix управляет им

---

## 7. АППАРАТНАЯ ПРИВЯЗКА

### Монитор
- Модель: DP-0
- Разрешение: 1920×1200
- Частота: 165Hz
- Куда: `modules/hardware/monitor.nix`

### Тачпад
- Модель: FTCS1000:01 2808:0222
- Natural scrolling
- Accel speed: -0.39
- Accel profile: adaptive
- Куда: `modules/hardware/touchpad.nix` (NixOS, не home-manager)

### Обои
- Файл: `/home/xmb03/Pictures/Wallpapers/gruvbox_image55.png`
- Установка: `feh --no-fehbg --bg-fill` (в `shell/.fehbg`)
- Проверить что файл существует после миграции

---

## 8. ЧЕКЛИСТ ПРОВЕРКИ

После каждого `nixos-rebuild switch` или `home-manager switch`:

```
[ ] i3 запустился
[ ] $mod+d — rofi с хардкод-цветами
[ ] $mod+a — rofi-wallpaper, без ошибок wal
[ ] Print — flameshot скриншот
[ ] Клавиши громкости (XF86Audio*) работают
[ ] kitty — цвета от stylix
[ ] zathura — PDF открывается
[ ] nvim — нет ошибок, neopywal не падает
[ ] dunst — уведомления работают
[ ] redshift — через минуту теплеет
[ ] nm-applet в трее
[ ] USB монтируется (udiskie)
[ ] Тачпад — natural scrolling
[ ] ${mod}+v — greenclip история
[ ] htop — установлен
[ ] zsh — autosuggestions, syntax-highlighting работают
[ ] zsh-completions — fpath настроен
[ ] Шрифт JetBrains Mono везде
[ ] Раскладка переключается (alt+shift)
[ ] ${mod}+Shift+e — выход из i3
[ ] Git репозиторий создан, commit + push на GitHub
```

---

## 9. ЧАСТЫЕ ОШИБКИ

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `i3: cannot include ...` | `include` в extraConfig не работают | Заменить include на весь текст в extraConfig |
| `nerdfonts.override` not found | unstable удалил этот синтаксис | Писать `nerd-fonts.jetbrains-mono` |
| `set_from_resource: unknown resource` | Xresources пуст или нет stylix | Включить `stylix.targets.i3` |
| `greenclip: command not found` | не добавлен в packages | `services.greenclip.enable = true` |
| `pactl: command not found` | pulseaudio не установлен | pipewire по умолчанию на NixOS |
| `flameshot: command not found` | не установлен | Добавить в packages |
| `nx-daemon` or permission errors | /nix/store монопольный доступ | `nix-collect-garbage`, `nix-store --repair` |
| `wallpaper.png` not found | путь неправильный | image = null если используешь base16Scheme |
| `redshift` не запускается | нет широты/долготы | Добавить latitude + longitude |
| `rofi: unable to import ...` | @import на несуществующий файл | Заменить @import на хардкод |
| `bash: ... command not found` | PATH не настроен | Проверить home.sessionPath в home-manager |
| `file doesn't exist at ...` | путь в home.file неверный | Использовать абсолютный путь к dotfiles/ |

---

## 10. ПОЛЕЗНЫЕ ССЫЛКИ

- Home Manager Options: https://nix-community.github.io/home-manager/options.xhtml
- Stylix Docs: https://stylix.danth.me/
- Nix Packages Search: https://search.nixos.org/packages
- NixOS i3: https://nixos.wiki/wiki/I3
- nix-colors: https://github.com/misterio77/nix-colors
- Base16 Schemes: https://github.com/tinted-theming/base16-schemes
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Home Manager Manual: https://nix-community.github.io/home-manager/

---

## 11. ПОРЯДОК ДЕЙСТВИЙ AI

1. Создать папку `~/nixos-config/` (удалить `~/nixdot/` если есть)
2. Создать `flake.nix` — inputs (nixpkgs, home-manager, stylix) + outputs
3. Создать `home.nix` — импортирует все модули из `./modules/`
4. Для КАЖДОГО конфига в `dotfiles/` создать соответствующий модуль в `modules/`
   - ❌ builtins.readFile — запрещён. Каждый конфиг переписывается вручную на Nix.
   - ❌ home.file — ЗАПРЕЩЁН ПОЛНОСТЬЮ. Никаких исключений.
   - Если нет HM-опций — AI ищет через WebSearch как это сделать на Nix.
   - i3/user/monitor.conf → hardware/monitor.nix (НЕ в extraConfig)
   - i3/user/settings.conf → i3-settings.nix + stylix (НЕ в extraConfig)
   - Остальные i3 файлы → extraConfig строкой вручную (без readFile)
5. Проверить что все wal-зависимости заменены на stylix
6. Проверить что все алиасы переписаны под NixOS
7. Сделать git snapshot (раздел 12)

## 12. GIT SNAPSHOT (В КОНЦЕ СЕССИИ)

После того как все модули созданы и проверены:

```bash
cd ~/nixos-config/
git init
git add -A
git commit -m "feat: full NixOS config from dotfiles"
gh repo create xmb03/nixos-config --public --push
git branch -M main
git push -u origin main
```

**Если нет gh CLI:**
```bash
# Создать репозиторий вручную на github.com, потом:
git remote add origin git@github.com:xmb03/nixos-config.git
git push -u origin main
```

## 13. ГЛОССАРИЙ

| Термин | Значение |
|--------|---------|
| **flake.nix** | Входная точка Nix проекта — описывает зависимости (inputs) и сборки (outputs) |
| **configuration.nix** | NixOS система — пакеты, сервисы, пользователи, драйверы |
| **home.nix** | Home-manager конфиг — пользовательские программы, конфиги, сервисы |
| **home-manager** | Декларативное управление ~/ конфигами |
| **stylix** | Система тем для NixOS (замена pywal) |
| **base16** | Стандарт цветовых схем (16 цветов) |
| **pywal** | Генератор цветов из обоев (был на Arch, НЕ использовать на NixOS) |
| **extraConfig** | Опция i3 — вставить сырой текст в i3 конфиг |
| **set_from_resource** | i3 команда — читает цвет из Xresources |
| **home.file** | Опция home-manager — линковка файлов |
| **libinput** | Драйвер ввода в NixOS (тачпад, мышь) |
| **module** | Nix-файл, который экспортирует `{ options, config, ... }` |
| **inputs** | Зависимости флейка (nixpkgs, home-manager, stylix) |
| **outputs** | Что собирает флейк (конфигурация NixOS или home-manager) |
