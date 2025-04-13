{
  pkgs,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.11";

    packages = with pkgs; [
      google-chrome
      obsidian
      neofetch
    ];
  };

  programs = {
    # apply stylix to neovim as well
    neovim.enable = true;

    git = {
      enable = true;
      userName = "tim-oster";
      userEmail = "tim.oster99@gmail.com";
      ignores = [
        "/.direnv*"
        "/.devenv*"
        ".aider*"
      ];
    };
  };

  custom = {
    stylix = {
      enable = true;
      fontSize = 12;
    };
    terminal.enable = true;
    devenv.enable = true;

    helix = {
      enable = true;
      defaultEditor = true;
    };
    cursor.enable = true;

    # TODO broken package
    # _1password = {
    #   enable = true;
    #   # 1password item: GitHub Workstation
    #   gpgSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    # };
  };
}
