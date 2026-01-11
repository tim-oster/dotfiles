{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom._1password;
in
{
  imports = [ ];

  options.custom._1password = {
    enable = lib.mkEnableOption "1password config";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux {
        services.gnome-keyring.enable = true;
        services.ssh-agent.enable = true;
      })

      {
        programs.ssh = {
          enable = true;
          extraConfig = lib.concatStringsSep "" (
            lib.optional pkgs.stdenv.isLinux ''
              Host *
                IdentityAgent ~/.1password/agent.sock
            ''
            ++ lib.optional pkgs.stdenv.isDarwin ''
              Host *
                IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            ''
          );
        };
      }
    ]
  );
}
