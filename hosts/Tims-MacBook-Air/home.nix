{
  pkgs-unstable,
  inputs,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [
    inputs.nix-direnv-trusted.homeModules.default
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.11";

    packages = [
      pkgs-unstable.rectangle-pro
    ];
  };

  custom = {
    shared.enable = true;
    stylix.fontSize = 12;

    karabiner-config.enable = true;
  };

  programs.ssh.settings."server.home" = {
    forwardAgent = true;
  };

  programs.ssh.settings."nixos-server" = {
    forwardAgent = true;
  };
}
