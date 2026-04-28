{ ... }:

{
  imports = [
    ../../common
    ../../common/printing.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  system.stateVersion = "25.11";

  services.syncthing = {
    enable = true;
    user = "jg";
    dataDir = "/home/jg/.local/share/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true; # Open firewall ports
  };
}
