{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.win-keyboard;
in
{
  imports = [ ];

  options.custom.win-keyboard = {
    enable = lib.mkEnableOption "enable windows keyboard";
  };

  config = lib.mkIf cfg.enable {
    system.keyboard = {
      enableKeyMapping = true;
    };
    system.activationScripts.postUserActivation.text = lib.mkAfter ''
      # setup custom keyboard layouts (requires restart)
      sudo rm -f "/Library/Keyboard Layouts/*osx-win-germany.keylayout"
      sudo cp "${./osx-win-germany.keylayout}" "/Library/Keyboard Layouts"
    '';
  };
}
