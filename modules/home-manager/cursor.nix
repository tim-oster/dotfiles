{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.cursor;
in
{
  imports = [ ];

  options.custom.cursor = {
    enable = lib.mkEnableOption "cursor config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkMerge [ [ pkgs.code-cursor ] ];

    home.file.".config/Cursor/User/settings.json" = {
      text = ''
        {
            "window.commandCenter": 1,
            "editor.fontSize": 12,
            "update.mode": "none",
            "update.showReleaseNotes": false,
            "extensions.autoUpdate": false,
            "go.alternateTools": {
                "go": "${lib.getExe pkgs.go}",
                "gopls": "${lib.getExe pkgs.gopls}",
                "dlv": "${lib.getExe pkgs.delve}",
            },
        }
      '';
    };
  };
}
