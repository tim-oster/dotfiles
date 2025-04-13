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
    gpgSigningKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Key to sign git commits with";
      default = null;
    };
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

      (lib.mkIf (cfg.gpgSigningKey != null) {
        programs.git.extraConfig =
          {
            gpg.format = "ssh";
            commit.gpgsign = true;
            user.signingkey = cfg.gpgSigningKey;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          }
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
      })
    ]
  );
}
