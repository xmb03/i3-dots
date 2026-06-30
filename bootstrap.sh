#!/usr/bin/env bash
set -euo pipefail

# dotfiles bootstrap — installs everything needed for xmb03/i3-dots
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/xmb03/i3-dots/main/bootstrap.sh)

DOTFILES_REPO="https://github.com/xmb03/i3-dots.git"
DOTFILES_DIR="$HOME/.config/dotfiles"
BACKUP_DIR="$HOME/.config/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo ":: bootstrap — xmb03/i3-dots"
mkdir -p "$BACKUP_DIR"

# ── 1. Install packages ──────────────────────────────────────────────────

install_arch() {
  local pkgs=(
    i3-wm rofi kitty neovim python-pywal feh i3status-rust dunst flameshot
    zsh zsh-autosuggestions zsh-syntax-highlighting
    xorg-xrandr xorg-xset xorg-xrdb xdotool xclip xss-lock i3lock
    redshift udiskie dex networkmanager network-manager-applet
    pipewire-pulse pulsemixer playerctl mpv-mpris
    bat btop mpv fastfetch picom
    ttf-jetbrains-mono-nerd
  )
  local aur_pkgs=(greenclip)

  # detect existing AUR helper, install yay if none found
  local aur=""
  if command -v paru &>/dev/null; then
    aur=paru
  elif command -v yay &>/dev/null; then
    aur=yay
  else
    echo ":: Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    aur=yay
  fi

  echo ":: Installing packages..."
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  "$aur" -S --needed --noconfirm "${aur_pkgs[@]}"

  echo ":: Enabling greenclip daemon..."
  systemctl --user enable --now greenclip
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

# ── 2. Clone / update dotfiles ───────────────────────────────────────────

if [ ! -d "$DOTFILES_DIR" ]; then
  echo ":: Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
elif git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo ":: dotfiles already present, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo ":: $DOTFILES_DIR exists but is not a git repo — skipping pull"
fi

# ── 3. Symlink configs ───────────────────────────────────────────────────

link_file() {
  local src="$1" dst="$2"

  if [ ! -e "$src" ]; then
    echo "    skipping $src — does not exist"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    # already a symlink — check if it points to the right place
    if [ "$(realpath "$dst")" = "$(realpath "$src")" ]; then
      return
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "    backing up $dst → $BACKUP_DIR/"
    local rel="${dst#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dst" "$BACKUP_DIR/$rel"
  fi

  ln -sf "$src" "$dst"
  echo "    linked $dst → $src"
}

echo ":: Symlinking configs..."
for dir in i3 kitty nvim rofi zathura gtk-3.0 gtk-4.0 fontconfig redshift wal dconf; do
  link_file "$DOTFILES_DIR/$dir" "$HOME/.config/$dir"
done

for f in .zshrc .bashrc .bash_profile .xprofile .fehbg .Xresources; do
  link_file "$DOTFILES_DIR/shell/$f" "$HOME/$f"
done

# ── 3b. Symlink pywal template outputs into app configs ──────────────────
# pywal generates files in ~/.cache/wal/ from templates in wal/templates/.
# These symlinks let apps `include` the generated colors without hardcoding.

echo ":: Symlinking wal template outputs..."
mkdir -p "$HOME/.config/zathura"
ln -sf "$HOME/.cache/wal/colors-zathurarc" "$HOME/.config/zathura/colors"
echo "    linked $HOME/.config/zathura/colors → $HOME/.cache/wal/colors-zathurarc"

# ── 3c. Install Xorg touchpad config ──────────────────────────────────────
# Settings in /etc/X11/xorg.conf.d/ survive device reconnects (unlike xinput).
echo ":: Installing Xorg touchpad config..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf > /dev/null < "$DOTFILES_DIR/xorg-conf.d/30-touchpad.conf"
echo "    installed /etc/X11/xorg.conf.d/30-touchpad.conf"

# ── 4. Setup wallpaper & pywal ───────────────────────────────────────────

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo ":: Creating $WALLPAPER_DIR — drop wallpapers here"
  mkdir -p "$WALLPAPER_DIR"
fi

# ── 4b. Firefox + Textfox + Pywalfox (optional) ──────────────────────────

read -rp ":: Install Firefox with Textfox theme + Pywalfox? (y/N): " install_firefox

case "$install_firefox" in
  [Yy]*)
    echo ":: Installing Firefox..."
    sudo pacman -S --needed --noconfirm firefox

    echo ":: Installing Pywalfox (AUR)..."
    "$aur" -S --needed --noconfirm python-pywalfox

    echo ":: Configuring Pywalfox native messaging..."
    pywalfox install

    echo ":: Cloning Textfox..."
    git clone https://github.com/adriankarlen/textfox.git /tmp/textfox

    echo ":: Running Textfox installer..."
    PROFILE_PATH=$(ls -d "$HOME/.mozilla/firefox/"*.default-release 2>/dev/null | head -1)
    if [ -n "$PROFILE_PATH" ]; then
      bash /tmp/textfox/tf-install.sh "$PROFILE_PATH"
    else
      echo ":: Firefox profile not found — run Firefox once first, then re-run:"
      echo "   bash /tmp/textfox/tf-install.sh"
    fi

    echo ":: Cleaning up..."
    rm -rf /tmp/textfox
    ;;
  *)
    echo ":: Skipping Firefox & Textfox"
    ;;
esac

# ── 5. Verify critical commands ──────────────────────────────────────────

echo ":: Checking critical commands..."
missing=0
for cmd in i3 kitty nvim rofi feh dunst flameshot zsh bat btop greenclip firefox; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "    MISSING: $cmd"
    missing=$((missing + 1))
  fi
done
if [ "$missing" -gt 0 ]; then
  echo "  ⚠ $missing command(s) not found — check package installation"
else
  echo "    all critical commands available"
fi

# ── 6. Done ──────────────────────────────────────────────────────────────

echo ""
echo "  ✓ Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "    1. Add wallpapers to ~/Pictures/Wallpapers/"
echo "    2. Run \$mod+a (or ~/.fehbg) to set a wallpaper"
echo "    3. Restart i3: \$mod+Shift+r"
echo "    4. Set zsh as default: chsh -s /usr/bin/zsh"
echo "    5. Install Pywalfox addon in Firefox: https://addons.mozilla.org/firefox/addon/pywalfox"
echo "    6. Open Firefox → click Pywalfox icon → \"Fetch Pywal colors\""
echo ""
