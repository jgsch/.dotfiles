set -e

DESKTOP=false
REINSTALL=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) DESKTOP=true ;;
    --reinstall) REINSTALL=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

#
# nix 
#

if $REINSTALL; then
  echo "[reinstall] removing existing Nix…"
  sudo rm -rf /nix /etc/nix /var/lib/nix /var/log/nix
  sudo rm -f  /etc/profile.d/nix.sh /etc/profile.d/nix.csh /etc/profile.d/nix.fish
  rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.config/nix ~/.cache/nix ~/.local/state/nix
fi

if ! which nix > /dev/null 2>&1; then
  echo "[install] installing Nix (single-user)…"

  # install
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

  # config
  mkdir -p ~/.config/nix
  echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

  # replace legacy nix with flake
  NIX_BIN="$(readlink -f "$(command -v nix)")"
  nix profile remove nix
  "$NIX_BIN" profile add nixpkgs#nix
fi

#
# miniconda
#

MINICONDA_DIR=${HOME}/.miniconda3

if [[ $REINSTALL && -d "$MINICONDA_DIR" ]]; then
  echo "[reinstall] removing existing Miniconda…"
  rm -rf ${MINICONDA_DIR}
fi

if [[ ! -d ${MINICONDA_DIR} ]]; then
  echo "[install] installing Miniconda…"

  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  TMP="$(mktemp)"
  curl -fsSL "${MINICONDA_URL}" -o "$TMP"

  bash "$TMP" -b -p "${INSTALL_DIR}"
  ${INSTALL_DIR}/condabin/conda config --set auto_activate_base false
fi

#
# rust
#

CARGO_DIR=${HOME}/.cargo

if [[ $REINSTALL && -d "$CARGO_DIR" ]]; then
  echo "[reinstall] removing existing Cargo…"
  rm -rf ${CARGO_DIR}
fi

if [[ ! -d ${CARGO_DIR} ]]; then
  echo "[install] installing Cargo…"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

PACKAGES=(
  nixpkgs#curl
  nixpkgs#docker
  nixpkgs#docker-compose
  nixpkgs#htop
  nixpkgs#just
  nixpkgs#fd
  nixpkgs#flatpak
  nixpkgs#git
  nixpkgs#gcc
  nixpkgs#ffmpeg
  nixpkgs#localsend
  nixpkgs#neovim
  nixpkgs#nodejs_24
  nixpkgs#lsd
  nixpkgs#pyright
  nixpkgs#neovim
  nixpkgs#starship
  nixpkgs#stow
  nixpkgs#tmux
  nixpkgs#ripgrep
  nixpkgs#vscodium
  nixpkgs#wget
)

DESKTOP_APPS=(
  nixpkgs#celluloid
  nixpkgs#foliate
  nixpkgs#keepassxc
  nixpkgs#onlyoffice-desktopeditors
  nixpkgs#gimp3
  nixpkgs#nicotine-plus
  nixpkgs#papirus-icon-theme
  nixpkgs#transmission_4
  nixpkgs#signal-desktop
  nixpkgs#ungoogled-chromium
  github:0xc000022070/zen-browser-flake
)

ADD=""
for PACKAGE in "${PACKAGES[@]}"; do
  ADD="${ADD} ${PACKAGE}"
done
if $DESKTOP; then
  for PACKAGE in "${DESKTOP_APPS[@]}"; do
    ADD="${ADD} ${PACKAGE}"
  done
fi

echo "[packages] installing requested packages…"
nix profile add $ADD

git config --global core.editor "nvim"
git config --global alias.car "commit --amend --no-edit"
git config --global alias.unstage "reset"
git config --global alias.ucommit "reset --soft HEAD^"

stow .

echo "✅ Done. Try: nix profile upgrade --all"
