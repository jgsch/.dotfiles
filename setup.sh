set -e

DESKTOP=false
RUST=false
DOCKER=false
REINSTALL=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) DESKTOP=true ;;
    --rust) RUST=true ;;
    --docker) DOCKER=true ;;
    --reinstall) REINSTALL=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

#
# nix
#

NIX_DIR="${HOME}/.nix-profile"

if [[ "$REINSTALL" == "true" && -d "$NIX_DIR" ]]; then
  echo "[nix] cleaning…"
  sudo rm -rf /nix /etc/nix /var/lib/nix /var/log/nix
  sudo rm -f  /etc/profile.d/nix.sh /etc/profile.d/nix.csh /etc/profile.d/nix.fish
  rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.config/nix ~/.cache/nix ~/.local/state/nix
fi

if [[ ! -d ${NIX_DIR} ]]; then
  echo "[nix] installing (single-user)…"

  # install
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

  . "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || . "$HOME/.nix-profile/etc/profile.d/nix-daemon.sh" 2>/dev/null

  # replace legacy nix with flake
  NIX_BIN="$(readlink -f "$(command -v nix)")"
  "$NIX_BIN" --extra-experimental-features 'nix-command flakes' profile remove nix
  "$NIX_BIN" --extra-experimental-features 'nix-command flakes' profile add nixpkgs#nix
fi

PACKAGES=(
  nixpkgs#curl
  nixpkgs#htop
  nixpkgs#just
  nixpkgs#fd
  nixpkgs#fzf
  nixpkgs#flatpak
  nixpkgs#git
  nixpkgs#gcc
  nixpkgs#ffmpeg
  nixpkgs#neovim
  nixpkgs#nodejs_24
  nixpkgs#lsd
  nixpkgs#pyright
  nixpkgs#starship
  nixpkgs#stow
  nixpkgs#tealdeer
  nixpkgs#tmux
  nixpkgs#ripgrep
  nixpkgs#wget
  nixpkgs#zoxide
)

ADD=""
for PACKAGE in "${PACKAGES[@]}"; do
  ADD="${ADD} ${PACKAGE}"
done

echo "[nix] installing base packages…"
nix --extra-experimental-features 'nix-command flakes' profile add $ADD

if $DESKTOP; then
  DESKTOP_APPS=(
    nixpkgs#amberol
    nixpkgs#foliate
    nixpkgs#keepassxc
    nixpkgs#onlyoffice-desktopeditors
    nixpkgs#gimp3
    nixpkgs#localsend
    nixpkgs#nicotine-plus
    nixpkgs#papirus-icon-theme
    nixpkgs#puddletag
    nixpkgs#transmission_4-gtk
    nixpkgs#signal-desktop
    nixpkgs#vscodium
    nixpkgs#ungoogled-chromium
    github:0xc000022070/zen-browser-flake
  )
  for PACKAGE in "${DESKTOP_APPS[@]}"; do
    ADD="${ADD} ${PACKAGE}"
  done

  echo "[dnf] installing cosmic-de"
  sudo dnf install -y @cosmic-desktop-environment

  echo "[dnf] installing packages"
  sudo dnf install -y alacritty celluloid

  echo "[nix] installing desktop packages…"
  nix --extra-experimental-features 'nix-command flakes' profile add $ADD
fi


#
# miniconda
#

MINICONDA_DIR=${HOME}/.miniconda3

if [[ "$REINSTALL" == "true" && -d "$MINICONDA_DIR" ]]; then
  echo "[conda] cleaning…"
  rm -rf ${MINICONDA_DIR}
fi

if [[ ! -d ${MINICONDA_DIR} ]]; then
  echo "[conda] installing…"

  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  TMP="${PWD}/miniconda.sh"
  curl -fsSL "${MINICONDA_URL}" -o "$TMP"

  bash "$TMP" -b -p "${MINICONDA_DIR}"
  ${MINICONDA_DIR}/condabin/conda config --set auto_activate_base false

  rm ${TMP}
fi

#
# rust
#

if $RUST; then
  CARGO_DIR=${HOME}/.cargo
  
  if [[ "$REINSTALL" == "true" && -d "$CARGO_DIR" ]]; then
    echo "[cargo] cleaning…"
    rm -rf ${CARGO_DIR}
  fi
  
  if [[ ! -d ${CARGO_DIR} ]]; then
    echo "[cargo] installing…"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
fi


#
# docker
#

if $DOCKER; then
  if ! which zsh >/dev/null 2>&1; then
    echo "[docker] installing…"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
  fi
fi


#
# setup git
# 
#

echo "[git] setup…"

git config --global core.editor "nvim"
git config --global alias.car "commit --amend --no-edit"
git config --global alias.unstage "reset"
git config --global alias.ucommit "reset --soft HEAD^"
git config pull.rebase true

#
# setup zsh
# 

echo "[zsh] setup…"

sudo dnf install -y zsh
ZSHPATH=$(which zsh)
sudo usermod -s "$ZSHPATH" "$USER"

#
# setup dotfiles
# 

echo "[dotfiles] setup…"

stow .

echo "✅ Done. Try: nix profile upgrade --all"
