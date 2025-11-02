{
  pkgs,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

  programs.home-manager.enable = true;

  home = {
    username = "server";
    homeDirectory = "/home/server";
    stateVersion = "24.11";
    packages = with pkgs; [
      tmux
    ];
  };

  custom = {
    stylix.enable = true;
    terminal.enable = true;
    devenv.enable = true;

    git = {
      enable = true;
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };
  };
}
