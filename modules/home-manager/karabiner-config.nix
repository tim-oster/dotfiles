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
  conditions = [
    {
      type = "device_if";
      identifiers = [ ergodox_identifiers ];
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
              devices = [
                {
                  identifiers = ergodox_identifiers;
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
                }
              ];
              complex_modifications = {
                rules = [
                  {
                    description = "Remap Ctrl Keys on ErgodoxEZ for Alacritty [nixos]";
                    manipulators = [
                      {
                        type = "basic";
                        from = {
                          key_code = "right_control";
                          modifiers.optional = [ "shift" ];
                        };
                        to = [
                          {
                            key_code = "right_control";
                            modifiers = [ "right_option" ];
                          }
                        ];
                      }
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
