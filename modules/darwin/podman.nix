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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkMerge [ [ pkgs.podman ] ];

    system.activationScripts.extraUserActivation.text = lib.mkAfter ''
      if [[ $(${lib.getExe pkgs.podman} system connection list --format json | jq length) -eq 0 ]]; then
        ${lib.getExe pkgs.podman} machine init podman-machine-default
      fi
    '';

    system.activationScripts.extraActivation.text = lib.mkAfter ''
      softwareupdate --install-rosetta --agree-to-license
    '';
  };
}
