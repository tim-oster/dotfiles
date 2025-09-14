{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.git;
in
{
  imports = [ ];

  options.custom.git = {
    enable = lib.mkEnableOption "git config";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "tim-oster";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "tim.oster99@gmail.com";
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
    };
    useOPSSHSign = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/allowed_signers".text = ''
      ${cfg.userEmail} ${cfg.signingKey}
    '';

    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      ignores = [
        "/.direnv*"
        "/.devenv*"
      ];
      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        commit.gpgsign = true;
        user.signingkey = cfg.signingKey;
      }
      // lib.optionalAttrs cfg.useOPSSHSign {
        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
  };
}
