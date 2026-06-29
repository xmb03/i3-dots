export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="/usr/bin:$PATH"
# Настройка истории команд
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Включаем стандартное автодополнение по Tab
autoload -Uz compinit
compinit

# ИНТЕГРАЦИЯ С PYWAL (Импортируем переменные и последовательности)
if [ -f "$HOME/.cache/wal/sequences" ]; then
    cat "$HOME/.cache/wal/sequences"
fi

if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
fi

# Подключаем установленные плагины
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# НАСТРОЙКА ЦВЕТОВ ДЛЯ НАБОРУ КОМАНД (Синтаксис)
# Используем цвета, которые сгенерировал wal
ZSH_HIGHLIGHT_STYLES[command]="fg=$color2,bold"       # Цвета команд (зеленый/акцент)
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$color6"            # Встроенные утилиты
ZSH_HIGHLIGHT_STYLES[alias]="fg=$color3"              # Алиасы
ZSH_HIGHLIGHT_STYLES[path]="fg=$color4"               # Пути к файлам
ZSH_HIGHLIGHT_STYLES[error]="fg=$color1"              # Ошибки

# Цвет для автопредложений (тусклый цвет из палитры wal)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$color8"

# НАСТРОЙКА ЦВЕТНОГО ПРОМПТА (Строка ввода)
# %F{$colorX} берет цвет из файла wal, %f — сбрасывает цвет в дефолт
PROMPT="%F{$color4}>%f "

# ═══════════════════════════════════════
# Aliases
# ═══════════════════════════════════════

# Обновление системы (Arch)
alias up='sudo pacman -Syu'

# Просмотр файлов (Bat вместо Cat)
alias b='bat'
alias cat='bat'       # Если хочешь заменить cat навсегда
alias c='clear'       # Очистка экрана

# Навигация
alias ..='cd ..'
alias ...='cd ../..'
alias l='ls -lh --color=auto'
alias la='ls -lha --color=auto'

# Редакторы и конфиги
alias n='nvim'

# Медиа
alias m='mpv'

# Мониторинг
alias top='btop'
alias mem='free -h'
alias disk='df -h'
alias f='fastfetch'

# copy # Функция для копирования содержимого файла в буфер обмена
y() {
    if [ -f "$1" ]; then
        cat "$1" | xclip -selection clipboard
        echo "Copied!"
    else
        echo "File not found."
    fi
}
