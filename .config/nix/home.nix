{
  config,
  pkgs,
  inputs,
  catppuccin,
  ...
}:

{
  home.username = "jg";
  home.homeDirectory = "/home/jg";
  home.stateVersion = "25.11";

  #
  # Catppuccin Theme (Home Manager level)
  #

  imports = [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    # GTK apps (Transmission, Firefox, etc.)
    gtk.enable = true;
    gtk.flavor = "mocha";
    gtk.accent = "blue";

    # Qt apps (KeePassXC, etc.)
    kvantum.enable = true;
    kvantum.flavor = "mocha";
    kvantum.accent = "blue";
  };

  # Apply Kvantum theme to Qt apps
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
  };

  home.packages = with pkgs; [
    kvantum
  ];

  programs.home-manager.enable = true;
}
