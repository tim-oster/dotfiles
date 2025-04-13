{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.stylix;
in
{
  imports = [ ];

  options = { };

  config = lib.mkIf cfg.enable {
    # set background image on macos
    system.activationScripts.extraUserActivation.text = lib.mkAfter ''
      osascript -e 'tell application "System Events" to set picture of every desktop to "${config.stylix.image}"'
    '';

    system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
