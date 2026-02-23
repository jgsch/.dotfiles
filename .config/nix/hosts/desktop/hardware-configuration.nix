# TODO: Generate this file on the desktop machine by running:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# Then replace this placeholder with the generated output.

{ lib, ... }:

{
  imports = [];

  # Replace everything below with the output of nixos-generate-config
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
