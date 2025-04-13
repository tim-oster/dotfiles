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
    theme = lib.mkOption {
      type = lib.types.str;
      default = "gruvbox-dark-medium";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix =
      let
        theme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";
      in
      {
        enable = true;
        polarity = "dark";
        base16Scheme = theme;
        image = pkgs.runCommand "image.png" { } ''
          COLOR=$(${lib.getExe pkgs.yq} -r .palette.base00 ${theme})
          ${lib.getExe pkgs.imagemagick} -size 10x10 xc:$COLOR $out
        '';
        imageScalingMode = "tile";
      };
  };
}
