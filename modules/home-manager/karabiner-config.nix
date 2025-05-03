{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.karabiner-config;
  ergodox_identifiers = {
    product_id = 18806;
    vendor_id = 12951;
    is_keyboard = true;
  };
  kyria_identifiers = {
    product_id = 32718;
    vendor_id = 36125;
    is_keyboard = true;
    is_pointing_device = false;
  };
  special_keyboards = [
    ergodox_identifiers
    kyria_identifiers
  ];
  conditions = [
    {
      type = "device_if";
      identifiers = special_keyboards;
    }
    {
      type = "frontmost_application_if";
      bundle_identifiers = [ "^org\\.alacritty$" ];
    }
  ];
in
{
  imports = [ ];

  options.custom.karabiner-config = {
    enable = lib.mkEnableOption "karabiner-config";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/karabiner/karabiner.json".text =
      let
        config = {
          profiles = [
            {
              name = "Default profile";
              selected = true;
              virtual_hid_keyboard = {
                country_code = 0;
                keyboard_type_v2 = "iso";
              };
              devices = map (keyboard: {
                identifiers = keyboard;
                simple_modifications = [
                  {
                    from = {
                      key_code = "left_command";
                    };
                    to = [ { key_code = "left_control"; } ];
                  }
                  {
                    from = {
                      key_code = "left_control";
                    };
                    to = [ { key_code = "left_command"; } ];
                  }
                  {
                    from = {
                      key_code = "right_command";
                    };
                    to = [ { key_code = "right_control"; } ];
                  }
                  {
                    from = {
                      key_code = "right_control";
                    };
                    to = [ { key_code = "right_command"; } ];
                  }
                ];
              }) special_keyboards;
              complex_modifications = {
                rules = [
                  {
                    description = "Remap Ctrl Keys on special keyboards for Alacritty [nixos]";
                    manipulators = [
                      # remap ctrl+shift+c to cmd+c in the terminal
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "c";
                          modifiers = {
                            "mandatory" = [
                              "control"
                              "shift"
                            ];
                          };
                        };
                        to = [
                          {
                            key_code = "c";
                            modifiers = [ "command" ];
                          }
                        ];
                      }
                      # remap ctrl+shift+v to cmd+v in the terminal
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "v";
                          modifiers = {
                            "mandatory" = [
                              "control"
                              "shift"
                            ];
                          };
                        };
                        to = [
                          {
                            key_code = "v";
                            modifiers = [ "command" ];
                          }
                        ];
                      }
                      # allow ctrl+option in terminal without remapping for window manager
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "right_control";
                          modifiers.optional = [ "right_option" ];
                        };
                        to = [
                          { key_code = "right_control"; }
                        ];
                      }
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "left_control";
                          modifiers.optional = [ "left_option" ];
                        };
                        to = [
                          { key_code = "left_control"; }
                        ];
                      }
                      # undo basic command<->ctrl remapping in terminal
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "right_command";
                          modifiers.optional = [ "any" ];
                        };
                        to = [
                          { key_code = "right_control"; }
                        ];
                      }
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "right_control";
                          modifiers.optional = [ "any" ];
                        };
                        to = [
                          { key_code = "right_command"; }
                        ];
                      }
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "left_command";
                          modifiers.optional = [ "any" ];
                        };
                        to = [
                          { key_code = "left_control"; }
                        ];
                      }
                      {
                        type = "basic";
                        conditions = conditions;
                        from = {
                          key_code = "left_control";
                          modifiers.optional = [ "any" ];
                        };
                        to = [
                          { key_code = "left_command"; }
                        ];
                      }
                    ];
                  }
                ];
              };
            }
          ];
        };
      in
      (builtins.toJSON config);
  };
}
