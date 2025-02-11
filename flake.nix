{
  description = "Tim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: rec {

    legacyPackages = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
      import inputs.nixpkgs {
        inherit system;
	config.allowUnfree = true;
      }
    );

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      pkgs = legacyPackages.x86_64-linux;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/default/configuration.nix
      ];
    };

#    homeConfigurations."tim@nixos" = home-manager.lib.homeManagerConfiguration {
#      pkgs = legacyPackages.x86_64-linux;
#      specialArgs = { inherit inputs; };
#      modules = [
#	./hosts/default/home.nix
#      ];
#    };

  };
}
