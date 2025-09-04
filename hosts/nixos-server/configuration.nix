{ config, pkgs, inputs, outputs, ... }:

let
  username = "server";
in
{
  imports =
    builtins.attrValues outputs.nixosModules
    ++ builtins.attrValues outputs.sharedModules
    ++ [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  system.stateVersion = "25.05";

  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd.luks.devices."luks-1aa6aca7-730a-4858-9cdb-581208c8b2c1".device = "/dev/disk/by-uuid/1aa6aca7-730a-4858-9cdb-581208c8b2c1";
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H workstation"];
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "${username}" = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      neovim
      just
    ];
  };

  custom = {
    locale.enable = true;

    stylix = {
      enable = true;
      theme = "gruvbox-dark-medium";
    };
  };

  services = {
    openssh.enable = true;
  };
}
