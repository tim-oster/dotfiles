{
  description = "Tim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {

      legacyPackages = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        pkgs = outputs.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/default/configuration.nix
        ];
      };

    };
}
