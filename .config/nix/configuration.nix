{ config, pkgs, inputs, ... }:



let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "35" ];  # Just the one you need
    buildToolsVersions = [ "35.0.0" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];  # Just one type
    abiVersions = [ "x86_64" ];  # Just one architecture
  };
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #
  # Networking
  #

  networking.hostName = "xyz"; 

  networking.networkmanager.enable = true;

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
  # user
  #

  users.users.jg = {
    isNormalUser = true;
    description = "jg";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };


  environment.variables.NH_FLAKE = "/etc/nixos";
  
  #
  # Keyring
  #

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = true;
  programs.seahorse.enable = true;

  # greetd login -> unlock keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # IMPORTANT: stop other ssh-agents from “winning” SSH_AUTH_SOCK
  programs.ssh.startAgent = false;

  # Make every app (Wayland apps too) see the right agent socket
  environment.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  
  # Fuse filesystem that dynamically populates contents of /bin 
  # and /usr/bin/ so that it contains all executables from the PATH 
  # of the requesting process.
  services.envfs.enable = true;


  # Android

  nixpkgs.config.android_sdk.accept_license = true;


  environment.systemPackages = with pkgs; [
    #
    # cli
    #
    adwaita-icon-theme
    android-tools
    android-studio
    androidComposition.androidsdk
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
    ffmpeg
    imagemagick
    opencode
    neovim
    nh
    nodejs_24
    ntfs3g
    lsd
    lsof
    lua-language-server
    pyright
    ruff
    starship
    stow
    stylua
    tealdeer
    tmux
    tree-sitter
    ripgrep
    (pkgs.python313.withPackages (ps: [ ps.mutagen ]))
    python313
    python313Packages.pip
    wget
    uv
    unzip
    zoxide
    zsh
    #
    # desktop apps
    #
    alacritty
    amberol
    celluloid
    firefox
    (pkgs.writeShellScriptBin "foliate" ''
      exec env GDK_BACKEND=x11 ${pkgs.foliate}/bin/foliate "$@"
    '')
    keepassxc
    onlyoffice-desktopeditors
    gimp3
    gnome-keyring
    localsend
    loupe
    nicotine-plus
    papers
    papirus-icon-theme
    protonvpn-gui
    puddletag
    transmission_4-gtk
    signal-desktop
    inputs.zen-browser.packages.${pkgs.system}.beta
    vlc
    vscodium
    #winboat
  ];
  
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

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
  ];
  
  boot.supportedFilesystems = [ "ntfs" ];
  services.udisks2.enable = true;
    
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 
}
