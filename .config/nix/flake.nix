{
  description = "NixOS configuration for laptop and desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cosmic-ext-extra-sessions = {
      url = "github:Drakulix/cosmic-ext-extra-sessions";
      flake = false;
    };

    cosmic-ext-alternative-startup = {
      url = "github:Drakulix/cosmic-ext-alternative-startup";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nur,
      catppuccin,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      sharedModules = [
        nur.modules.nixos.default
        catppuccin.nixosModules.catppuccin
      ];
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs system nixpkgs-unstable; };
          modules = [ ./hosts/laptop ] ++ sharedModules;
        };

        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs system nixpkgs-unstable; };
          modules = [ ./hosts/desktop ] ++ sharedModules;
        };
      };
    };
}
