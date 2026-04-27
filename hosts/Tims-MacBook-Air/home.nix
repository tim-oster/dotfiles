{
  pkgs-unstable,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

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

  programs.ssh.matchBlocks."server.home" = {
    forwardAgent = true;
  };

  programs.ssh.matchBlocks."nixos-server" = {
    forwardAgent = true;
  };
}
