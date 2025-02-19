{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.stylix;
in
{
  imports = [ ];

  options.custom.stylix = {
    enable = lib.mkEnableOption "stylix config";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      cursor.size = 8;

      fonts = {
        sizes =
          let
            size = 10;
          in
          {
            applications = size;
            desktop = size;
            popups = size;
            terminal = size;
          };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
      };
    };
  };
}
