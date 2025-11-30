{
  description = "Tim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin?ref=nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      legacyPackages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = (builtins.attrValues (import ./overlays));
        }
      );

      unstablePackages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        }
      );

      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      sharedModules = import ./modules/shared;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations."nixos-workstation" = nixpkgs.lib.nixosSystem {
        pkgs = outputs.legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = outputs.unstablePackages.x86_64-linux;
        };
        modules = [
          ./hosts/nixos-workstation/configuration.nix
        ];
      };

      nixosConfigurations."nixos-laptop" = nixpkgs.lib.nixosSystem {
        pkgs = outputs.legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = outputs.unstablePackages.x86_64-linux;
        };
        modules = [
          ./hosts/nixos-laptop/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t480s
        ];
      };

      nixosConfigurations."nixos-server" = nixpkgs.lib.nixosSystem {
        pkgs = outputs.legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = outputs.unstablePackages.x86_64-linux;
        };
        modules = [
          ./hosts/nixos-server/configuration.nix
        ];
      };

      darwinConfigurations."Tims-MacBook-Air" = nix-darwin.lib.darwinSystem {
        pkgs = outputs.legacyPackages.aarch64-darwin;
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = outputs.unstablePackages.aarch64-darwin;
        };
        modules = [
          ./hosts/Tims-MacBook-Air/configuration.nix
        ];
      };
    };
}
