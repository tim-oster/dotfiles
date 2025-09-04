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
    username = "server";
    homeDirectory = "/home/server";
    stateVersion = "24.11";

    packages = with pkgs; [];
  };

  custom = {
# TODO use shared.enable = true; with special server mode
      stylix.enable = lib.mkDefault true;
      terminal.enable = lib.mkDefault true;
      devenv.enable = lib.mkDefault true;

  };
    programs = {
      helix = {
        enable = lib.mkDefault true;
        defaultEditor = lib.mkDefault true;
      };
    
      git = {
        enable = true;
        userName = "tim-oster";
        userEmail = "tim.oster99@gmail.com";
      };
    };
}
