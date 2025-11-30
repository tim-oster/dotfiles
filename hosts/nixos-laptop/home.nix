{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

  programs.home-manager.enable = true;

  home = {
    username = "tim";
    homeDirectory = "/home/tim";
    stateVersion = "24.11";

    packages = with pkgs; [
      pavucontrol
      nautilus
      (pkgs.callPackage ../../modules/packages/vial.nix { })
    ];
  };

  custom = {
    shared.enable = true;
    wifimenu.enable = true;
    vscode.enable = true;
    cursor.enable = true;

    redshift = {
      enable = true;
      nightTemp = 3000;
    };

    stylix = {
      fontSize = 8;
      terminalFontSize = 6;
    };

    i3 = {
      enable = true;
      startup = [
        "${lib.getExe pkgs._1password-gui} --silent"
        "${lib.getExe pkgs.networkmanagerapplet}"
        "blueman-applet" # installed in configuration.nix
      ];
      terminal = pkgs.alacritty;
    };
  };
}
