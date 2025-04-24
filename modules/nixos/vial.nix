{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.vial;
in
{
  imports = [ ];

  options.custom.vial = {
    enable = lib.mkEnableOption "enable vial udev rules";
    groupMembers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.plugdev = {
      members = cfg.groupMembers;
    };

    services.udev.extraRules = lib.mkAfter ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
