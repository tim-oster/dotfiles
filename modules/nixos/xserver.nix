{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.xserver;
in
{
  imports = [ ];

  options.custom.xserver = {
    enable = lib.mkEnableOption "xserver config";
    displayWidth = lib.mkOption {
      type = lib.types.int;
    };
    displayHeight = lib.mkOption {
      type = lib.types.int;
    };
    useStylix = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    videoDriver = lib.mkOption {
      type = lib.types.str;
    };
    autoLoginUser = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      windowManager.i3.enable = true;
      windowManager.i3.extraPackages = [ ];

      videoDrivers = [ cfg.videoDriver ];

      resolutions = [
        {
          x = cfg.displayWidth;
          y = cfg.displayHeight;
        }
      ];

      displayManager.autoLogin.user = cfg.autoLoginUser; # disabled if null

      displayManager.lightdm = {
        enable = true;
        extraSeatDefaults = ''
          user-session = none+i3
        '';

        greeters.gtk.enable = false;
        greeters.mini = {
          enable = true;
          user = "tim";
          extraConfig =
            ''
              [greeter]
              show-password-label = true
              password-label-text = Password
              invalid-password-text = Access Denied
              show-input-cursor = false
              password-alignment = left
              password-input-width = 40
            ''
            + (
              if cfg.useStylix then
                ''
                  [greeter-theme]
                  font = Sans
                  font-size = 1em
                  font-weight = normal
                  font-style = normal
                  background-image = ""
                  password-border-width = 0
                  password-border-radius = 0

                  background-color = #${config.lib.stylix.colors.base00}
                  text-color = #${config.lib.stylix.colors.base06}
                  error-color = #${config.lib.stylix.colors.base08}
                  window-color = #${config.lib.stylix.colors.base02}
                  border-color = #${config.lib.stylix.colors.base02}
                  border-width = 0px

                  password-color = #${config.lib.stylix.colors.base06}
                  password-background-color = #${config.lib.stylix.colors.base03}
                  password-border-color = #${config.lib.stylix.colors.base03}
                ''
              else
                ""
            );
        };
      };
    };
  };
}
