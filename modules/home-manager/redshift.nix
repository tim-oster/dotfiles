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
    geo-provider = lib.mkOption {
      type = lib.types.str;
      default = "manual";
    };
    night-temp = lib.mkOption {
      type = lib.types.str;
      default = "4500";
    };
  };

  config = lib.mkIf cfg.enable {
    services.redshift = {
      enable = true;
      provider = cfg.geo-provider;
    };

    home.packages = lib.mkMerge [
      [
        (pkgs.writeShellScriptBin "redshift-on" "redshift -P -O ${cfg.night-temp}")
        (pkgs.writeShellScriptBin "redshift-off" "redshift -x")
      ]
    ];
  };
}
