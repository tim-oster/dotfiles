{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.devenv;
in
{
  imports = [ ];

  options.custom.devenv = {
    enable = lib.mkEnableOption "devenv config";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    programs.git.delta = {
      enable = true;
      options.side-by-side = true;
    };

    programs.lazygit.enable = true;

    home.packages = lib.mkMerge [
      [
        pkgs.delve # go debugger
      ]
    ];
  };
}
