#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  Rafay's Hyprland Dotfiles Installer — NIGHTWIRE
#  github.com/Hirafay/Rafay-Hyprland-Arch
#  Supports: Arch, CachyOS, EndeavourOS, Manjaro, Garuda
# ─────────────────────────────────────────────────────────────

set -uo pipefail

# ── colors ───────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'
  DIM='\033[2m';    NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; MAGENTA=''
  BOLD=''; DIM=''; NC=''
fi

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/rafay-hyprland-install.log"

log()  { printf '[%s] %s\n' "$(date -u +%F' '%T)" "$*" >> "$LOG_FILE"; }
ok()   { echo -e "${GREEN}[OK]${NC}  $1"; log "[OK]  $1"; }
info() { echo -e "${CYAN}[..]${NC}  $1"; log "[..]  $1"; }
warn() { echo -e "${YELLOW}[!!]${NC}  $1"; log "[!!]  $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; log "[ERR] $1"; }
die()  { err "$1"; exit "${2:-1}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# ── sanity checks (skipped for pure-info subcommands) ───────
sanity_check() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] && die "Don't run as root. Run as your normal user."
  command -v pacman &>/dev/null || die "Arch-based distro required (pacman not found)."
}

# ── unattended mode ──────────────────────────────────────────
UNATTENDED="${RAFAY_UNATTENDED:-0}"
PRESET_ARG="${RAFAY_PRESET:-}"

ask() {
  # ask PROMPT DEFAULT  -> echoes Y/N
  local prompt="$1" default="${2:-N}" ans
  if [[ "$UNATTENDED" == "1" ]]; then
    echo "$default"; return
  fi
  echo -ne "${YELLOW}[??]${NC}  $prompt [${default}] "
  read -r ans
  [[ -z "$ans" ]] && ans="$default"
  [[ "$ans" =~ ^[Yy]$ ]] && echo "Y" || echo "N"
}

ask_choice() {
  # ask_choice "prompt" default "1 2 3 4"
  local prompt="$1" default="$2" valid="$3" ans
  if [[ "$UNATTENDED" == "1" ]]; then
    echo "$default"; return
  fi
  while true; do
    echo -ne "${YELLOW}[??]${NC}  $prompt [$default] "
    read -r ans
    [[ -z "$ans" ]] && ans="$default"
    if [[ " $valid " == *" $ans "* ]]; then
      echo "$ans"; return
    fi
    warn "Invalid choice. Options: $valid"
  done
}

# ── banner ───────────────────────────────────────────────────
show_banner() {
  clear
  echo
  echo -e "${GREEN}${BOLD}"
  cat << 'EOF'
   ╔══════════════════════════════════════════╗
   ║  N I G H T W I R E  //  rafay-hyprland  ║
   ║  phosphor · void · hyprland · hud-rice   ║
   ╚══════════════════════════════════════════╝
EOF
  echo -e "${NC}"
  echo -e "  ${DIM}github.com/Hirafay/Rafay-Hyprland-Arch${NC}"
  echo -e "  ${DIM}log → $LOG_FILE${NC}"
  echo
}

# ── packages: split into presets ─────────────────────────────
PKGS_CORE=(
  # hyprland
  hyprland hyprlock hypridle hyprpicker hyprshot
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  polkit-kde-agent qt5-wayland qt6-wayland jq

  # bar / launcher / wallpaper
  waybar wofi swww swaync

  # audio visualizer (powers the waybar cava widget)
  cava

  # terminal / shell
  kitty fish starship zoxide fastfetch

  # display manager + qt full stack for the NIGHTWIRE greeter
  # (qt6-shadertools + qt6-languageserver aren't strictly required by Main.qml
  #  but are pulled by most hyprland/qt6ct setups and keep things reliable)
  sddm qt6-svg qt6-declarative qt6-5compat qt6-virtualkeyboard qt6-multimedia
  qt6-shadertools qt6-wayland

  # file manager
  thunar thunar-archive-plugin file-roller gvfs

  # fonts
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji noto-fonts-cjk

  # screenshot / clipboard / notifications
  grim slurp wl-clipboard cliphist dunst libnotify

  # system
  brightnessctl playerctl network-manager-applet blueman pavucontrol
  xdg-user-dirs power-profiles-daemon

  # cli tooling
  btop eza bat fd ripgrep

  # GTK / Qt theming
  papirus-icon-theme qt6ct

  # build
  git base-devel unzip imagemagick
)

PKGS_FULL_EXTRA=(
  # additional niceties for the "Full rice" preset
  mpv imv zathura zathura-pdf-mupdf
  starship zoxide
  ttf-font-awesome
  pamixer wireplumber
)

PKGS_DEV_EXTRA=(
  # dev tools
  neovim tmux github-cli lazygit
  python python-pip nodejs npm
  gcc cmake make meson ninja
  xdotool  # some e2e scripts still expect it
)

AUR_PKGS=(
  waypaper
  bibata-cursor-theme
  swayosd-git
)

# Which config dirs actually ship (trust nothing — this is the real list)
# Verified against `ls -d */` on the repo root at install time.
detect_configs() {
  CONFIGS=()
  for d in hypr waybar kitty fish wofi fastfetch waypaper dunst swaync swayosd btop gtk-3.0 qt6ct; do
    [[ -d "$DOTFILES_DIR/$d" ]] && CONFIGS+=("$d")
  done
}

# ─────────────────────────────────────────────────────────────
#  Dep audit — before we touch anything
# ─────────────────────────────────────────────────────────────
dep_audit() {
  echo -e "${BOLD}${CYAN}── DEPENDENCY AUDIT ──────────────────────────────${NC}"
  local missing=() installed=()
  for p in hyprland waybar kitty wofi sddm; do
    if pacman -Qi "$p" &>/dev/null; then
      installed+=("$p")
    else
      missing+=("$p")
    fi
  done
  if [[ ${#installed[@]} -gt 0 ]]; then
    ok "Already installed: ${installed[*]}"
  fi
  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "Will install: ${missing[*]}"
  fi

  # hyprland version check — Lua config needs 0.55+
  if command -v Hyprland &>/dev/null; then
    local ver
    ver="$(Hyprland --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -n1 || echo "0.0.0")"
    local major minor
    major="$(echo "$ver" | cut -d. -f1)"
    minor="$(echo "$ver" | cut -d. -f2)"
    if (( major > 0 || minor >= 55 )); then
      ok "Hyprland $ver detected — supports Lua config"
    else
      warn "Hyprland $ver is older than 0.55 — Lua config will not load until upgrade"
    fi
  else
    info "Hyprland not yet installed — will install current version"
  fi

  # SDDM status
  if pacman -Qi sddm &>/dev/null && systemctl is-enabled sddm &>/dev/null; then
    ok "SDDM is installed and enabled"
  fi

  # GPU quick-detect (for NVIDIA env warnings)
  if lspci 2>/dev/null | grep -qi 'vga.*nvidia\|3d.*nvidia'; then
    warn "NVIDIA GPU detected — make sure nvidia / nvidia-utils / libva-nvidia-driver are installed"
  fi

  # other display managers already enabled?
  for dm in gdm lightdm lxdm; do
    if systemctl is-enabled "$dm" &>/dev/null; then
      warn "Conflicting DM detected: $dm — the installer will disable it"
    fi
  done

  echo
}

# ─────────────────────────────────────────────────────────────
#  SDDM THEMES
# ─────────────────────────────────────────────────────────────
install_sddm_theme() {
  local theme="$1" repo="$2"
  local target="/usr/share/sddm/themes/$theme"

  info "Installing SDDM theme: $theme"
  if [[ -d "$target" ]]; then
    warn "$theme already present — skipping"
    return 0
  fi
  local tmp
  tmp="$(mktemp -d)"
  if ! git clone --depth=1 "$repo" "$tmp/$theme" >>"$LOG_FILE" 2>&1; then
    warn "clone failed for $theme — see log"
    rm -rf "$tmp"
    return 1
  fi
  if [[ -f "$tmp/$theme/Main.qml" ]] || [[ -f "$tmp/$theme/metadata.desktop" ]]; then
    sudo cp -r "$tmp/$theme" "$target"
  else
    local inner
    inner="$(find "$tmp/$theme" -maxdepth 3 -name 'metadata.desktop' -printf '%h\n' | head -n1)"
    [[ -n "$inner" ]] && sudo cp -r "$inner" "$target" \
      || { warn "could not locate theme files for $theme"; rm -rf "$tmp"; return 1; }
  fi
  rm -rf "$tmp"
  ok "$theme installed"
}

install_our_sddm_theme() {
  local src="$DOTFILES_DIR/sddm-theme"
  local dst="/usr/share/sddm/themes/nightwire"

  if [[ ! -d "$src" ]]; then
    warn "sddm-theme/ missing from repo — skipping"
    return 1
  fi
  if [[ -d "$dst" ]]; then
    warn "nightwire SDDM theme exists — refreshing"
    sudo rm -rf "$dst"
  fi
  sudo cp -r "$src" "$dst"

  # drop a wallpaper in so the QML has something to show
  if [[ -f "$HOME/.config/hypr/wall.png" ]]; then
    sudo cp "$HOME/.config/hypr/wall.png" "$dst/wall.png"
  elif [[ -f "$DOTFILES_DIR/wallpapers/darkforest.png" ]]; then
    sudo cp "$DOTFILES_DIR/wallpapers/darkforest.png" "$dst/wall.png"
  elif [[ -f "$DOTFILES_DIR/preview.png" ]]; then
    sudo cp "$DOTFILES_DIR/preview.png" "$dst/wall.png"
  fi
  ok "nightwire SDDM theme installed"
  return 0
}

pick_sddm_theme() {
  if [[ "$UNATTENDED" == "1" ]]; then
    install_our_sddm_theme >&2 && echo "nightwire" || echo ""
    return
  fi

  echo "" >&2
  echo -e "${BOLD}SDDM theme:${NC}" >&2
  echo -e "  ${GREEN}1)${NC} nightwire  (ours — ships with repo)" >&2
  echo -e "  ${GREEN}2)${NC} sugar-candy    (polished, config-driven)" >&2
  echo -e "  ${GREEN}3)${NC} astronaut      (video bg, cyberpunk)" >&2
  echo -e "  ${GREEN}4)${NC} corners        (minimal dark)" >&2
  echo -e "  ${GREEN}5)${NC} keep default" >&2
  echo -ne "  Choice [1-5]: " >&2
  read -r tc
  case "$tc" in
    1) install_our_sddm_theme >&2 && echo "nightwire" || echo "" ;;
    2) install_sddm_theme "sugar-candy" "https://framagit.org/MarianArlt/sddm-sugar-candy.git" >&2 && echo "sugar-candy" || echo "" ;;
    3) install_sddm_theme "astronaut" "https://github.com/Keyitdev/sddm-astronaut-theme.git" >&2 && echo "astronaut" || echo "" ;;
    4) install_sddm_theme "corners" "https://github.com/aczw/sddm-theme-corners.git" >&2 && echo "corners" || echo "" ;;
    *) echo "" ;;
  esac
}

apply_sddm_theme() {
  local theme="$1"
  if [[ -z "$theme" ]]; then
    warn "Using SDDM default theme"
    return
  fi
  sudo mkdir -p /etc/sddm.conf.d
  sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << SDDM
[Theme]
Current=$theme
CursorTheme=Bibata-Modern-Classic
Font=JetBrainsMono Nerd Font
SDDM
  ok "SDDM theme set to: $theme"
}

# ─────────────────────────────────────────────────────────────
#  AUR helper
# ─────────────────────────────────────────────────────────────
install_aur_helper() {
  echo -e "${BOLD}AUR helper${NC}"
  if command -v yay &>/dev/null || command -v paru &>/dev/null; then
    ok "AUR helper already present"
    AUR_HELPER="$(command -v yay || command -v paru)"
    return
  fi
  info "Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel >>"$LOG_FILE" 2>&1
  rm -rf /tmp/yay-install
  git clone --quiet https://aur.archlinux.org/yay.git /tmp/yay-install
  pushd /tmp/yay-install >/dev/null
  makepkg -si --noconfirm >>"$LOG_FILE" 2>&1 || die "yay build failed — see $LOG_FILE"
  popd >/dev/null
  rm -rf /tmp/yay-install
  AUR_HELPER="$(command -v yay)"
  ok "yay installed"
}

install_packages() {
  local -n _pkgs=$1
  info "Installing ${#_pkgs[@]} packages (this takes a while on fresh installs)..."
  if ! "$AUR_HELPER" -S --needed --noconfirm "${_pkgs[@]}" >>"$LOG_FILE" 2>&1; then
    warn "Some packages failed — check $LOG_FILE. Continuing with what installed."
  else
    ok "Packages installed"
  fi
}

# ─────────────────────────────────────────────────────────────
#  CONFIG COPY
# ─────────────────────────────────────────────────────────────
backup_configs() {
  local backup_dir="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"
  local found=0
  for cfg in "${CONFIGS[@]}"; do
    if [[ -d "$HOME/.config/$cfg" ]]; then
      cp -r "$HOME/.config/$cfg" "$backup_dir/"
      warn "Backed up ~/.config/$cfg"
      found=1
    fi
  done
  [[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$backup_dir/" && found=1
  if [[ $found -eq 1 ]]; then
    ok "Backup saved to $backup_dir"
  else
    rmdir "$backup_dir" 2>/dev/null || true
    info "Nothing to back up"
  fi
}

install_dotfiles() {
  mkdir -p "$HOME/.config"
  for cfg in "${CONFIGS[@]}"; do
    if [[ -d "$DOTFILES_DIR/$cfg" ]]; then
      rm -rf "$HOME/.config/$cfg"
      cp -r "$DOTFILES_DIR/$cfg" "$HOME/.config/$cfg"
      ok "Installed ~/.config/$cfg"
    fi
  done
  if [[ -f "$DOTFILES_DIR/starship.toml" ]]; then
    cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    ok "Installed starship.toml"
  fi

  # Hyprland Lua entrypoint sanity
  if [[ -f "$HOME/.config/hypr/hyprland.lua" ]]; then
    ok "Hyprland Lua config in place (hyprland.lua + modules)"
  else
    warn "hyprland.lua missing — Hyprland 0.55+ won't start"
  fi

  # mark scripts executable
  if [[ -d "$HOME/.config/hypr/scripts" ]]; then
    chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null
    ok "Scripts marked executable"
  fi
}

install_wallpapers() {
  mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"

  # preview.png is the signature wallpaper → treat as a wallpaper too
  if [[ -f "$DOTFILES_DIR/preview.png" ]]; then
    cp -n "$DOTFILES_DIR/preview.png" "$HOME/Pictures/Wallpapers/nightwire-preview.png"
  fi
  if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
    shopt -s nullglob
    for w in "$DOTFILES_DIR/wallpapers/"*.{png,jpg,jpeg}; do
      cp -n "$w" "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
    done
    shopt -u nullglob
  fi
  ok "Wallpapers copied into ~/Pictures/Wallpapers"

  # pick the primary wallpaper
  local wall="$HOME/Pictures/Wallpapers/darkforest.png"
  [[ -f "$wall" ]] || wall="$HOME/Pictures/Wallpapers/nightwire-preview.png"
  [[ -f "$wall" ]] || wall="$(find "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) 2>/dev/null | head -n1)"

  if [[ -n "$wall" && -f "$wall" ]]; then
    cp "$wall" "$HOME/.config/hypr/wall.png"
    cp "$wall" "$HOME/.config/hypr/hyprlock.png"
    [[ ! -f "$HOME/.face.icon" ]] && cp "$wall" "$HOME/.face.icon" 2>/dev/null || true
    ok "Hyprlock + SDDM wallpaper → $(basename "$wall")"

    mkdir -p "$HOME/.config/waypaper"
    if [[ ! -f "$HOME/.config/waypaper/config.ini" ]]; then
      cat > "$HOME/.config/waypaper/config.ini" << WAYPAPER
[Settings]
language = en
folder = $HOME/Pictures/Wallpapers
wallpaper = $wall
backend = swww
monitors = All
fill = fill
sort = name
color = #05070a
subfolders = False
show_hidden = False
show_gifs_only = False
post_command =
number_of_columns = 3
swww_transition_type = any
swww_transition_step = 90
swww_transition_angle = 0
swww_transition_duration = 2
swww_transition_fps = 60
WAYPAPER
    else
      sed -i "s|^wallpaper = .*|wallpaper = $wall|" "$HOME/.config/waypaper/config.ini"
      sed -i "s|^folder = .*|folder = $HOME/Pictures/Wallpapers|" "$HOME/.config/waypaper/config.ini"
    fi
    ok "waypaper primed to restore $wall on login"

    # push live if a Hyprland session is already running
    if command -v swww &>/dev/null && pgrep -x Hyprland &>/dev/null; then
      pgrep -x swww-daemon >/dev/null || (swww-daemon &) 2>/dev/null
      sleep 1
      swww img "$wall" --transition-type grow --transition-duration 1 >/dev/null 2>&1 \
        && ok "Wallpaper applied live" \
        || warn "swww live-apply failed — will restore on next session"
    fi
  else
    warn "No wallpaper found — set one with SUPER+W after login"
  fi
}

setup_cursor() {
  mkdir -p "$HOME/.icons/default"
  cat > "$HOME/.icons/default/index.theme" << CURSOR
[Icon Theme]
Name=Default
Comment=Default cursor theme
Inherits=Bibata-Modern-Classic
CURSOR
  command -v gsettings &>/dev/null && \
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
  ok "Cursor → Bibata-Modern-Classic"
}

setup_fish() {
  local fish_path
  fish_path="$(command -v fish 2>/dev/null)"
  [[ -z "$fish_path" ]] && { warn "fish not installed, skipping chsh"; return; }
  if [[ "${SHELL:-}" != "$fish_path" ]]; then
    grep -q "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$fish_path" 2>/dev/null && ok "Fish set as default shell" \
      || warn "chsh failed — set manually: chsh -s $fish_path"
  else
    ok "Fish already default shell"
  fi
}

setup_sddm() {
  for dm in gdm lightdm lxdm; do
    if systemctl is-enabled "$dm" &>/dev/null; then
      sudo systemctl disable "$dm" >>"$LOG_FILE" 2>&1 \
        && info "Disabled conflicting DM: $dm"
    fi
  done
  sudo systemctl enable sddm >>"$LOG_FILE" 2>&1 && ok "SDDM enabled"
  local theme
  theme="$(pick_sddm_theme)"
  apply_sddm_theme "$theme"
}

setup_audio() {
  info "Installing Pipewire audio stack..."
  "$AUR_HELPER" -S --needed --noconfirm \
    pipewire pipewire-pulse pipewire-alsa wireplumber >>"$LOG_FILE" 2>&1 || true
  systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
    && ok "Pipewire enabled" \
    || warn "Pipewire will start on next login"
}

enable_services() {
  systemctl is-enabled bluetooth &>/dev/null \
    || sudo systemctl enable bluetooth 2>/dev/null \
    && ok "bluetooth enabled"
  systemctl is-enabled power-profiles-daemon &>/dev/null \
    || sudo systemctl enable power-profiles-daemon 2>/dev/null \
    && ok "power-profiles-daemon enabled"
  xdg-user-dirs-update 2>/dev/null || true
}

print_outro() {
  echo
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}${BOLD}  Install complete. Reboot and pick Hyprland at SDDM.${NC}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo -e "  ${BOLD}First-time keybinds:${NC}"
  echo -e "  SUPER + ENTER      → Terminal"
  echo -e "  SUPER + SPACE      → Launcher"
  echo -e "  SUPER + /          → Keybind cheatsheet"
  echo -e "  SUPER + X          → Lock screen"
  echo -e "  SUPER + SHIFT + P  → Power menu"
  echo -e "  Print              → Screenshot (region)"
  echo
  echo -e "  ${DIM}Install log: $LOG_FILE${NC}"
  echo
}

# ─────────────────────────────────────────────────────────────
#  PRESETS
# ─────────────────────────────────────────────────────────────
pick_preset() {
  if [[ -n "$PRESET_ARG" ]]; then
    echo "$PRESET_ARG"; return
  fi
  if [[ "$UNATTENDED" == "1" ]]; then
    echo "full"; return
  fi
  echo >&2
  echo -e "${BOLD}Choose a preset:${NC}" >&2
  echo -e "  ${GREEN}1)${NC} ${BOLD}Minimal${NC}  — just the rice (Hyprland + bar + term + launcher)" >&2
  echo -e "  ${GREEN}2)${NC} ${BOLD}Full${NC}     — everything shipped (recommended)" >&2
  echo -e "  ${GREEN}3)${NC} ${BOLD}Dev${NC}      — Full + neovim/tmux/gh/lazygit/python/node" >&2
  echo -ne "  Choice [1-3, default 2]: " >&2
  local c; read -r c; c="${c:-2}"
  case "$c" in
    1) echo "minimal" ;;
    3) echo "dev" ;;
    *) echo "full" ;;
  esac
}

build_pkg_list_from_preset() {
  local preset="$1"
  SELECTED_PKGS=("${PKGS_CORE[@]}")
  case "$preset" in
    full|dev) SELECTED_PKGS+=("${PKGS_FULL_EXTRA[@]}") ;;
  esac
  case "$preset" in
    dev) SELECTED_PKGS+=("${PKGS_DEV_EXTRA[@]}") ;;
  esac
}

# ─────────────────────────────────────────────────────────────
#  INSTALL
# ─────────────────────────────────────────────────────────────
do_install() {
  show_banner
  echo -e "${GREEN}${BOLD}  >> INSTALL MODE${NC}"
  echo

  detect_configs
  dep_audit

  local preset backup audio
  preset="$(pick_preset)"
  info "Preset: $preset"
  build_pkg_list_from_preset "$preset"
  echo

  backup="$(ask 'Backup existing ~/.config entries first?' 'Y')"
  audio="$(ask 'Install + enable Pipewire audio stack?' 'Y')"
  echo

  local step=1 total=9
  banner_step() {
    echo
    echo -e "${CYAN}${BOLD}[$step/$total] $1${NC}"
    step=$((step+1))
  }

  banner_step "AUR helper"
  install_aur_helper

  banner_step "Installing packages (${#SELECTED_PKGS[@]} + ${#AUR_PKGS[@]} AUR)"
  install_packages SELECTED_PKGS
  install_packages AUR_PKGS

  banner_step "Audio"
  if [[ "$audio" == "Y" ]]; then setup_audio; else warn "Skipped audio"; fi

  banner_step "Backup"
  if [[ "$backup" == "Y" ]]; then backup_configs; else warn "Skipped backup"; fi

  banner_step "Dotfiles"
  install_dotfiles

  banner_step "Wallpapers + waypaper state"
  install_wallpapers

  banner_step "Default shell + cursor"
  setup_fish
  setup_cursor

  banner_step "SDDM"
  setup_sddm

  banner_step "Services + user dirs"
  enable_services

  print_outro
}

# ─────────────────────────────────────────────────────────────
#  Partial flows
# ─────────────────────────────────────────────────────────────
do_sddm_only() {
  show_banner
  echo -e "${MAGENTA}${BOLD}  >> SDDM-ONLY MODE${NC}"
  echo
  install_aur_helper
  "$AUR_HELPER" -S --needed --noconfirm sddm qt6-svg qt6-declarative qt6-5compat qt6-virtualkeyboard qt6-multimedia >>"$LOG_FILE" 2>&1 \
    && ok "SDDM + Qt6 deps installed" || warn "SDDM install hit issues"
  setup_sddm
  print_outro
}

do_wallpaper_only() {
  show_banner
  echo -e "${MAGENTA}${BOLD}  >> WALLPAPER-ONLY MODE${NC}"
  echo
  install_wallpapers
  echo
  ok "Done"
}

# ─────────────────────────────────────────────────────────────
#  UNINSTALL
# ─────────────────────────────────────────────────────────────
do_uninstall() {
  show_banner
  echo -e "${RED}${BOLD}  >> UNINSTALL MODE${NC}"
  echo
  echo -e "${RED}  This removes dotfiles, our SDDM theme, and Hyprland-stack packages.${NC}"
  local confirm
  confirm="$(ask 'Are you sure?' 'N')"
  [[ "$confirm" == "Y" ]] || { warn "Aborted."; exit 0; }

  detect_configs
  info "Removing dotfiles..."
  for cfg in "${CONFIGS[@]}"; do
    [[ -d "$HOME/.config/$cfg" ]] && rm -rf "$HOME/.config/$cfg" && warn "Removed ~/.config/$cfg"
  done
  [[ -f "$HOME/.config/starship.toml" ]] && rm -f "$HOME/.config/starship.toml"
  [[ -d "$HOME/.icons/default" ]] && rm -rf "$HOME/.icons/default"
  ok "Dotfiles removed"

  info "Removing SDDM themes installed by this script..."
  for theme in nightwire sugar-candy astronaut corners; do
    [[ -d "/usr/share/sddm/themes/$theme" ]] && sudo rm -rf "/usr/share/sddm/themes/$theme"
  done
  sudo rm -f /etc/sddm.conf.d/theme.conf
  ok "SDDM themes removed"

  info "Removing packages..."
  install_aur_helper 2>/dev/null
  "$AUR_HELPER" -Rns --noconfirm \
    hyprland hyprlock hypridle hyprpicker hyprshot \
    waybar kitty fish starship wofi swww swaync \
    fastfetch dunst waypaper bibata-cursor-theme sddm \
    swayosd-git 2>>"$LOG_FILE" \
    && ok "Packages removed" \
    || warn "Some packages weren't installed — skipped"

  sudo systemctl disable sddm 2>/dev/null && ok "SDDM disabled"

  echo
  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}${BOLD}  Uninstall complete. Rice is gone.${NC}"
  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ─────────────────────────────────────────────────────────────
#  HELP
# ─────────────────────────────────────────────────────────────
show_help() {
  cat << HELP
Rafay-Hyprland-Arch installer

Usage: ./install.sh [command]

Commands:
  install           Interactive install (default if run with no args and no RAFAY_UNATTENDED)
  sddm              Install + configure SDDM only
  wallpaper         Reinstall wallpapers only
  uninstall         Remove dotfiles, SDDM themes, packages
  menu              Show the interactive menu (default when run with no args interactively)
  help              This text

Environment:
  RAFAY_UNATTENDED=1       Skip all prompts (yes to backup, yes to audio, Full preset, nightwire SDDM)
  RAFAY_PRESET=minimal|full|dev
                           Set the preset without being asked

Log: $LOG_FILE
HELP
}

# ─────────────────────────────────────────────────────────────
#  MAIN MENU
# ─────────────────────────────────────────────────────────────
show_menu() {
  show_banner
  echo -e "  ${BOLD}What do you want to do?${NC}"
  echo
  echo -e "  ${GREEN}${BOLD}1)${NC} Install          (full rice)"
  echo -e "  ${CYAN}${BOLD}2)${NC} SDDM only        (just the greeter)"
  echo -e "  ${MAGENTA}${BOLD}3)${NC} Wallpaper only   (reset wall + waypaper state)"
  echo -e "  ${YELLOW}${BOLD}4)${NC} Uninstall"
  echo -e "  ${DIM}5)${NC} Help"
  echo -e "  ${RED}${BOLD}6)${NC} Quit"
  echo
  echo -ne "  Enter choice [1-6]: "
  read -r choice
  case "$choice" in
    1) do_install ;;
    2) do_sddm_only ;;
    3) do_wallpaper_only ;;
    4) do_uninstall ;;
    5) show_help ;;
    6|q|Q) echo; warn "Bye."; exit 0 ;;
    *) err "Invalid option." ; exit 1 ;;
  esac
}

# ─────────────────────────────────────────────────────────────
#  ENTRY
# ─────────────────────────────────────────────────────────────
log "─── installer invoked: args=$* unattended=$UNATTENDED preset=${PRESET_ARG:-ask} ───"

cmd="${1:-menu}"

# help and raw-menu-print don't need sanity checks
case "$cmd" in
  help|-h|--help) show_help; exit 0 ;;
esac

sanity_check

case "$cmd" in
  install)   do_install ;;
  sddm)      do_sddm_only ;;
  wallpaper) do_wallpaper_only ;;
  uninstall) do_uninstall ;;
  menu)      show_menu ;;
  *)         err "Unknown command: $cmd"; show_help; exit 1 ;;
esac
