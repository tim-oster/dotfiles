{
  description = "Tim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      self,
      nixpkgs,
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

      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      sharedModules = import ./modules/shared;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations."nixos-workstation" = nixpkgs.lib.nixosSystem {
        pkgs = outputs.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/nixos-workstation/configuration.nix
        ];
      };

      darwinConfigurations."Tims-MacBook-Air" = nix-darwin.lib.darwinSystem {
        pkgs = outputs.legacyPackages.aarch64-darwin;
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/Tims-MacBook-Air/configuration.nix
        ];
      };
    };
}
