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
      {
        services.gnome-keyring.enable = true;
        services.ssh-agent.enable = true;

        programs.ssh = {
          enable = true;
          extraConfig = ''
            Host *
              IdentityAgent ~/.1password/agent.sock
          '';
        };
      }

      (lib.mkIf (cfg.gpgSigningKey != null) {
        programs.git.extraConfig = {
          gpg.format = "ssh";
          "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign = true;
          user.signingkey = cfg.gpgSigningKey;
        };
      })
    ]
  );
}
