{
  description = "A flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    transmission-4-0-5-nixpkgs = {
      url = "github:NixOS/nixpkgs/eb04659fc2623c05643ed14633423758d3c6c6a4";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, nur, transmission-4-0-5-nixpkgs, catppuccin, ... }@inputs:
  let
    system = "x86_64-linux";
    transmission405NixPkgs = import transmission-4-0-5-nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      xyz = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs system;
        };

        modules = [
          ./configuration.nix

          nur.modules.nixos.default

	  catppuccin.nixosModules.catppuccin

          ({ pkgs, ... }: {
            environment.systemPackages = [
              transmission405NixPkgs.transmission_4-gtk
              pkgs.nur.repos.Ev357.helium
            ];
          })
        ];
      };
    };
  };
}
