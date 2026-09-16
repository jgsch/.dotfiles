{
  config,
  pkgs,
  inputs,
  ...
}:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ./cosmic-ext-niri.nix
  ];

  #
  # Boot
  #

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  #
  # Networking
  #

  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    # Localsend: 53317
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  #
  # Locales
  #

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };

  # Configure console keymap
  console.keyMap = "fr_CH";

  #
  # User
  #

  users.users.jg = {
    isNormalUser = true;
    description = "jg";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  environment.variables.NH_FLAKE = "/etc/nixos";

  #
  # Keyring
  #

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.cosmic-greeter.enableGnomeKeyring = true;

  #
  # Printer
  #

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.brlaser # Brother laser printers
  ];

  #
  # COSMIC desktop
  #

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.xwayland.enable = true;
  services.system76-scheduler.enable = true;

  #
  # Packages
  #

  nixpkgs.config.allowUnfree = true;

  # Fuse filesystem that dynamically populates contents of /bin
  # and /usr/bin/ so that it contains all executables from the PATH
  # of the requesting process.
  services.envfs.enable = true;

  # for dynamically linked binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    wayland
    libxkbcommon
    libglvnd
  ];

  security.polkit.enable = true;

  # Android

  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = with pkgs; [
    #
    # cli
    #
    appimage-run
    adwaita-icon-theme
    claude-code
    copilot-language-server
    curl
    devenv
    direnv
    htop
    jq
    just
    fd
    fzf
    git
    gcc
    gnumake
    ffmpeg
    imagemagick
    unstable.opencode
    openssl
    mise
    neovim
    nmap
    nh
    nodejs_24
    ntfs3g
    lsd
    lsof
    lua-language-server
    pyright
    ruff
    rsync
    starship
    stow
    stylua
    tealdeer
    tmux
    tree-sitter
    ripgrep
    rtk
    (pkgs.python313.withPackages (ps: [
      ps.mutagen
      ps.yt-dlp
    ]))
    pciutils
    poppler-utils
    pre-commit
    python314
    python314Packages.pip
    wget
    uv
    unzip
    wl-clipboard
    zoxide
    zsh
    #
    # desktop apps
    #
    alacritty
    amberol
    brightnessctl
    celluloid
    firefox
    (symlinkJoin {
      name = "foliate";
      paths = [ foliate ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/foliate \
          --set GDK_BACKEND x11
      '';
    })
    unstable.herdr
    keepassxc
    onlyoffice-desktopeditors
    gimp3
    gnome-keyring
    localsend
    loupe
    mkvtoolnix
    orca-slicer
    nicotine-plus
    papers
    papirus-icon-theme
    parted
    podman
    podman-compose
    protonvpn-gui
    nur.repos.Ev357.helium
    puddletag
    transmission_4-gtk
    # rpi-imager
    tor-browser
    signal-desktop
    sshfs-fuse
    sunsetr
    inputs.zen-browser.packages.${pkgs.system}.beta
    vlc
    vscodium
    wimlib
    #winboat
  ];

  #
  # Programs
  #

  programs.zsh = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.starship = {
  };

  programs.git = {
    enable = true;

    config = {
      core = {
        editor = "nvim";
      };

      alias = {
        car = "commit --amend --no-edit";
        unstage = "reset";
        ucommit = "reset --soft HEAD^";
      };

      pull = {
        rebase = true;
      };
    };
  };

  #
  # Fonts
  #

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    (pkgs.stdenvNoCC.mkDerivation {
      name = "custom-fonts";
      src = ./fonts;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src/*.ttf $src/*.otf $out/share/fonts/truetype/
      '';
    })
  ];

  #
  # Services
  #

  services.udisks2.enable = true;

  #
  # Nix settings
  #

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
