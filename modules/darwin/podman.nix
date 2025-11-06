{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.podman;
in
{
  imports = [ ];

  options.custom.podman = {
    enable = lib.mkEnableOption "enable podman";
    asUser = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkMerge [
      [
        pkgs.podman
        pkgs.docker-compose
        (pkgs.writeShellScriptBin "docker" ''
          podman "$@"
        '')
      ]
    ];

    system.activationScripts.extraActivation.text = lib.mkAfter ''
      if [[ $(su -l "${cfg.asUser}" -c "${lib.getExe pkgs.podman} system connection list --format json | jq length") -eq 0 ]]; then
        su -l "${cfg.asUser}" -c "${lib.getExe pkgs.podman} machine init podman-machine-default"
      fi

      sudo -u ${cfg.asUser} softwareupdate --install-rosetta --agree-to-license
    '';
  };
}
