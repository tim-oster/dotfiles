{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home = {
    username = "tim";
    homeDirectory = "/home/tim";
    stateVersion = "24.11";

    packages = with pkgs; [
      google-chrome
      obsidian
      pavucontrol
      neofetch
    ];
  };

  programs = {
    # apply stylix to neovim as well
    neovim.enable = true;

    git = {
      enable = true;
      userName = "tim-oster";
      userEmail = "tim.oster99@gmail.com";
    };
  };

  custom = {
    wifimenu.enable = true;
    stylix.enable = true;
    terminal.enable = true;
    devenv.enable = true;

    redshift = {
      enable = true;
      geoProvider = "geoclue2";
      nightTemp = 3000;
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };
    cursor.enable = true;

    i3 = {
      enable = true;
      startup = [
        "${lib.getExe pkgs._1password-gui} --silent"
        "${lib.getExe pkgs.networkmanagerapplet}"
        "blueman-applet" # installed in configuration.nix
      ];
      terminal = pkgs.alacritty;
    };

    _1password = {
      enable = true;
      # 1password item: GitHub Workstation
      gpgSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };
  };
}
