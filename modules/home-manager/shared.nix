{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.shared;
in
{
  imports = [ ];

  options.custom.shared = {
    enable = lib.mkEnableOption "shared config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkMerge [
      [
        pkgs.google-chrome
        pkgs.obsidian
        pkgs.neofetch
      ]
    ];

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
      stylix.enable = lib.mkDefault true;
      terminal.enable = lib.mkDefault true;
      devenv.enable = lib.mkDefault true;

      helix = {
        enable = lib.mkDefault true;
        defaultEditor = lib.mkDefault true;
      };
      cursor.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault true;

      _1password = {
        enable = lib.mkDefault true;
        # 1password item: GitHub Workstation
        gpgSigningKey = lib.mkDefault "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
      };
    };
  };
}
