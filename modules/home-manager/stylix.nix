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
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 9;
    };
    terminalFontSize = lib.mkOption {
      type = with lib.types; nullOr int;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      # nixos only
      cursor = {
        size = 8;
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
      };

      # nixos and darwin
      fonts = {
        sizes = {
          applications = cfg.fontSize;
          desktop = cfg.fontSize;
          popups = cfg.fontSize;
          terminal = cfg.terminalFontSize or cfg.fontSize;
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
