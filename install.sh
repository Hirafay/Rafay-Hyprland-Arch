#!/bin/bash

# ─────────────────────────────────────────────────────────────
#  Rafay's Hyprland Dotfiles Installer
#  github.com/Hirafay/Rafay-Hyprland-Arch
#  Supports: Arch Linux + any Arch-based distro
# ─────────────────────────────────────────────────────────────

set -e

# ── colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC}  $1"; }
info() { echo -e "${CYAN}[..]${NC}  $1"; }
warn() { echo -e "${YELLOW}[!!]${NC}  $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

# ── sanity checks ────────────────────────────────────────────
[[ $EUID -eq 0 ]] && err "Don't run as root. Run as your normal user."
command -v pacman &>/dev/null || err "Arch-based distro required."

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── banner ───────────────────────────────────────────────────
show_banner() {
  clear
  echo -e "${GREEN}${BOLD}"
  cat << 'EOF'
  ██████╗  █████╗ ███████╗ █████╗ ██╗   ██╗
  ██╔══██╗██╔══██╗██╔════╝██╔══██╗╚██╗ ██╔╝
  ██████╔╝███████║█████╗  ███████║ ╚████╔╝
  ██╔══██╗██╔══██║██╔══╝  ██╔══██║  ╚██╔╝
  ██║  ██║██║  ██║██║     ██║  ██║   ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝   ╚═╝
EOF
  echo -e "${NC}"
  echo -e "  ${GREEN}${BOLD}Rafay's Hyprland Config${NC}"
  echo -e "  ${CYAN}github.com/Hirafay/Rafay-Hyprland-Arch${NC}"
  echo ""
  echo -e "  Stack: ${BOLD}Hyprland · Waybar · Kitty · Fish · Wofi${NC}"
  echo -e "         ${BOLD}Hyprlock · Hypridle · SDDM · Fastfetch${NC}"
  echo ""
}

# ── packages ─────────────────────────────────────────────────
PKGS=(
  hyprland
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  qt5-wayland
  qt6-wayland
  polkit-kde-agent
  waybar
  wofi
  swww
  kitty
  fish
  starship
  hyprlock
  hypridle
  sddm
  thunar
  gvfs
  fastfetch
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  grim
  slurp
  wl-clipboard
  cliphist
  dunst
  libnotify
  brightnessctl
  playerctl
  network-manager-applet
  blueman
  pavucontrol
  xdg-user-dirs
  git
  base-devel
)

AUR_PKGS=(
  waypaper
  bibata-cursor-theme
  sddm-theme-silent
)

CONFIGS=(hypr waybar kitty fish wofi fastfetch)

# ─────────────────────────────────────────────────────────────
#  INSTALL
# ─────────────────────────────────────────────────────────────
do_install() {
  show_banner
  echo -e "${GREEN}${BOLD}  >> INSTALL MODE${NC}"
  echo ""

  # backup prompt
  BACKUP=false
  echo -ne "${YELLOW}[??]${NC}  Backup existing configs before overwriting? [y/N] "
  read -r bk
  [[ "$bk" =~ ^[Yy]$ ]] && BACKUP=true
  echo ""

  # audio prompt
  SETUP_AUDIO=false
  echo -ne "${YELLOW}[??]${NC}  Enable Pipewire audio? (recommended for fresh install) [y/N] "
  read -r aud
  [[ "$aud" =~ ^[Yy]$ ]] && SETUP_AUDIO=true
  echo ""

  # ── 1: yay ─────────────────────────────────────────────────
  echo -e "${BOLD}[1/8] AUR helper${NC}"
  if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    cd /tmp/yay-install && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    rm -rf /tmp/yay-install
    ok "yay installed"
  else
    ok "yay already installed"
  fi
  echo ""

  # ── 2: packages ────────────────────────────────────────────
  echo -e "${BOLD}[2/8] Installing packages...${NC}"
  info "This may take a while on a fresh install"
  yay -S --needed --noconfirm "${PKGS[@]}" "${AUR_PKGS[@]}" \
    || err "Package install failed. Check your internet."
  ok "All packages installed"
  echo ""

  # ── 3: audio ───────────────────────────────────────────────
  echo -e "${BOLD}[3/8] Audio${NC}"
  if [[ "$SETUP_AUDIO" == true ]]; then
    yay -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
      && ok "Pipewire enabled" \
      || warn "Pipewire will start on next login"
  else
    warn "Skipped audio setup"
  fi
  echo ""

  # ── 4: backup ──────────────────────────────────────────────
  echo -e "${BOLD}[4/8] Backup${NC}"
  if [[ "$BACKUP" == true ]]; then
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for cfg in "${CONFIGS[@]}"; do
      [[ -d "$HOME/.config/$cfg" ]] \
        && cp -r "$HOME/.config/$cfg" "$BACKUP_DIR/" \
        && warn "Backed up ~/.config/$cfg"
    done
    [[ -f "$HOME/.config/starship.toml" ]] \
      && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
    ok "Backup saved to $BACKUP_DIR"
  else
    warn "Skipping backup"
  fi
  echo ""

  # ── 5: dotfiles ────────────────────────────────────────────
  echo -e "${BOLD}[5/8] Dotfiles${NC}"
  mkdir -p "$HOME/.config"
  for cfg in "${CONFIGS[@]}"; do
    if [[ -d "$DOTFILES_DIR/$cfg" ]]; then
      rm -rf "$HOME/.config/$cfg"
      cp -r "$DOTFILES_DIR/$cfg" "$HOME/.config/$cfg"
      ok "Installed $cfg"
    else
      warn "$cfg not found in dotfiles — skipping"
    fi
  done
  [[ -f "$DOTFILES_DIR/starship.toml" ]] \
    && cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml" \
    && ok "Installed starship.toml"
  echo ""

  # ── 6: fish shell ──────────────────────────────────────────
  echo -e "${BOLD}[6/8] Default shell${NC}"
  FISH_PATH="$(which fish)"
  if [[ "$SHELL" != "$FISH_PATH" ]]; then
    grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
    chsh -s "$FISH_PATH"
    ok "Fish set as default shell"
  else
    ok "Fish already default"
  fi
  echo ""

  # ── 7: cursor ──────────────────────────────────────────────
  echo -e "${BOLD}[7/8] Cursor${NC}"
  mkdir -p "$HOME/.icons/default"
  cat > "$HOME/.icons/default/index.theme" << CURSOR
[Icon Theme]
Name=Default
Comment=Default cursor theme
Inherits=Bibata-Modern-Classic
CURSOR
  command -v gsettings &>/dev/null && \
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
  ok "Cursor set to Bibata-Modern-Classic"
  echo ""

  # ── 8: SDDM ────────────────────────────────────────────────
  echo -e "${BOLD}[8/8] SDDM${NC}"
  sudo systemctl enable sddm
  sudo mkdir -p /etc/sddm.conf.d
  sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << SDDM
[Theme]
Current=silent
SDDM
  ok "SDDM enabled with Silent theme"
  echo ""

  xdg-user-dirs-update 2>/dev/null || true

  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}${BOLD}  Done! Reboot and select Hyprland from SDDM.${NC}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${BOLD}Keybinds:${NC}"
  echo -e "  SUPER + ENTER   → Terminal"
  echo -e "  SUPER + SPACE   → Launcher"
  echo -e "  SUPER + Q       → Close window"
  echo -e "  SUPER + L       → Lock screen"
  echo -e "  SUPER + W       → Wallpaper picker"
  echo -e "  Print           → Screenshot"
  echo ""
}

# ─────────────────────────────────────────────────────────────
#  UNINSTALL
# ─────────────────────────────────────────────────────────────
do_uninstall() {
  show_banner
  echo -e "${RED}${BOLD}  >> UNINSTALL MODE${NC}"
  echo ""
  echo -e "${RED}  This will remove all dotfiles and packages.${NC}"
  echo -ne "${YELLOW}[??]${NC}  Are you sure? This cannot be undone. [y/N] "
  read -r confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }
  echo ""

  info "Removing dotfiles..."
  for cfg in "${CONFIGS[@]}"; do
    [[ -d "$HOME/.config/$cfg" ]] \
      && rm -rf "$HOME/.config/$cfg" \
      && warn "Removed ~/.config/$cfg"
  done
  [[ -f "$HOME/.config/starship.toml" ]] && rm -f "$HOME/.config/starship.toml"
  [[ -d "$HOME/.icons/default" ]] && rm -rf "$HOME/.icons/default"
  ok "Dotfiles removed"
  echo ""

  info "Removing packages..."
  yay -Rns --noconfirm \
    hyprland waybar kitty fish starship wofi swww \
    hyprlock hypridle fastfetch dunst waypaper \
    bibata-cursor-theme sddm sddm-theme-silent 2>/dev/null \
    && ok "Packages removed" \
    || warn "Some packages may not have been installed — skipping"
  echo ""

  info "Disabling SDDM..."
  sudo systemctl disable sddm 2>/dev/null && ok "SDDM disabled" || warn "SDDM wasn't enabled"
  sudo rm -f /etc/sddm.conf.d/theme.conf
  echo ""

  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}${BOLD}  Uninstall complete. Rice is gone.${NC}"
  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# ─────────────────────────────────────────────────────────────
#  MAIN MENU
# ─────────────────────────────────────────────────────────────
show_banner

echo -e "  ${BOLD}What do you want to do?${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}1)${NC} Install"
echo -e "  ${RED}${BOLD}2)${NC} Quit"
echo -e "  ${YELLOW}${BOLD}3)${NC} Uninstall"
echo ""
echo -ne "  Enter choice [1/2/3]: "
read -r choice

case "$choice" in
  1) do_install ;;
  2) echo ""; warn "Bye."; exit 0 ;;
  3) do_uninstall ;;
  *) err "Invalid option. Run the script again." ;;
esac
