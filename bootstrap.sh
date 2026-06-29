#!/usr/bin/env bash
set -euo pipefail

# dotfiles bootstrap — installs everything needed for xmb03/i3-dots
# Usage: curl -fsSL https://raw.githubusercontent.com/xmb03/i3-dots/main/bootstrap.sh | bash

DOTFILES_REPO="git@github.com:xmb03/i3-dots.git"
DOTFILES_DIR="$HOME/.config/dotfiles"

echo ":: bootstrap — xmb03/i3-dots"

# ── 1. Install packages ──────────────────────────────────────────────────

install_arch() {
  local pkgs=(
    i3-wm rofi kitty neovim python-pywal feh i3status-rust dunst flameshot
    zsh zsh-autosuggestions zsh-syntax-highlighting firefox
    xorg-xrandr xorg-xset xorg-xrdb xdotool xclip xss-lock i3lock
    redshift udiskie dex network-manager-applet
    pipewire-pulse pulsemixer playerctl
    bat btop mpv fastfetch picom
    ttf-jetbrains-mono-nerd
  )
  local aur_pkgs=(greenclip)

  if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    echo ":: Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
  fi
  local aur="${AUR_HELPER:-yay}"

  echo ":: Installing packages..."
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  "$aur" -S --needed --noconfirm "${aur_pkgs[@]}"
}

case "$(uname -o 2>/dev/null || uname -s)" in
  GNU/Linux)
    if command -v pacman &>/dev/null; then
      install_arch
    elif command -v apt &>/dev/null; then
      echo ":: Debian/Ubuntu detected — not yet supported"
      echo "   Install packages manually: sudo apt install i3 rofi kitty neovim ..."
    else
      echo ":: Unknown distro — install packages manually"
    fi
    ;;
  *)
    echo ":: Unsupported OS"
    exit 1
    ;;
esac

# ── 2. Clone dotfiles ────────────────────────────────────────────────────

if [ ! -d "$DOTFILES_DIR" ]; then
  echo ":: Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo ":: dotfiles already present, pulling latest..."
  git -C "$DOTFILES_DIR" pull
fi

# ── 3. Symlink configs ───────────────────────────────────────────────────

echo ":: Symlinking configs..."
mkdir -p "$HOME/.config"
for dir in i3 kitty nvim rofi zathura gtk-3.0 gtk-4.0 fontconfig redshift wal; do
  src="$DOTFILES_DIR/$dir"
  dst="$HOME/.config/$dir"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
done

# shell configs
for f in .zshrc .bashrc .bash_profile .xprofile .fehbg .Xresources; do
  src="$DOTFILES_DIR/shell/$f"
  dst="$HOME/$f"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
done

# ── 4. Setup wallpaper & pywal ───────────────────────────────────────────

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo ":: Creating $WALLPAPER_DIR — drop wallpapers here"
  mkdir -p "$WALLPAPER_DIR"
fi

# ── 5. Done ──────────────────────────────────────────────────────────────

echo ""
echo "  ✓ Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "    1. Add wallpapers to ~/Pictures/Wallpapers/"
echo "    2. Run \$mod+a (or ~/.fehbg) to set a wallpaper"
echo "    3. Restart i3: \$mod+Shift+r"
echo "    4. Set zsh as default: chsh -s /usr/bin/zsh"
echo ""
