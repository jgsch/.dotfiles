{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
in
{
  imports = [
    ../../common
    ../../common/android.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    unstable.winboat
  ];

  virtualisation.docker.enable = true;
  users.users.jg.extraGroups = [ "docker" ];

  networking.hostName = "desktop";

  services.syncthing = {
    enable = true;
    user = "jg";
    dataDir = "/home/jg/.local/share/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true; # Open firewall ports
  };
}
