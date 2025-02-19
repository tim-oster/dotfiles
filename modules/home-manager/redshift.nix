{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.redshift;
in
{
  imports = [ ];

  options.custom.redshift = {
    enable = lib.mkEnableOption "redshift bindings";
    geoProvider = lib.mkOption {
      type = lib.types.str;
      default = "manual";
    };
    nightTemp = lib.mkOption {
      type = lib.types.int;
      default = 4500;
    };
  };

  config = lib.mkIf cfg.enable {
    services.redshift = {
      enable = true;
      provider = cfg.geoProvider;
    };

    home.packages = lib.mkMerge [
      [
        (pkgs.writeShellScriptBin "redshift-on" "redshift -P -O ${toString cfg.nightTemp}")
        (pkgs.writeShellScriptBin "redshift-off" "redshift -x")
      ]
    ];
  };
}
