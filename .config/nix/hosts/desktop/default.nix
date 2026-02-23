{ ... }:

{
  imports = [
    ../../common
    ../../common/android.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  networking.hostName = "desktop";

  system.stateVersion = "25.11";
}
