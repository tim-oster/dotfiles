{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.terminal;
in
{
  imports = [ ];

  options.custom.terminal = {
    enable = lib.mkEnableOption "terminal config";
  };

  config = lib.mkIf cfg.enable {
    home.shell.enableShellIntegration = true;

    programs.alacritty = {
      enable = true;
      settings = {
        keyboard.bindings = [
          {
            key = "I";
            mods = "Alt|Shift";
            action = "ToggleViMode";
          }
          {
            key = "Escape";
            mode = "Vi";
            action = "ToggleViMode";
          }
        ];
      };
    };

    # https://podman-desktop.io/docs/migrating-from-docker/using-the-docker_host-environment-variables
    programs.fish = {
      enable = true;
      interactiveShellInit = lib.concatStringsSep "" (
        [
          ''
            set fish_greeting # Disable greeting
          ''
        ]
        ++ lib.optional (pkgs.stdenv.isDarwin && config.services.podman.enable) ''
          export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
        ''
        ++ lib.optional (pkgs.stdenv.isLinux && config.services.podman.enable) ''
          export DOCKER_HOST="unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')"
        ''
      );
    };

    programs.fzf.enable = true;

    # better cat
    programs.bat.enable = true;
    home.shellAliases.cat = "bat";

    # better ls
    programs.lsd = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    home.shellAliases = {
      "ls" = lib.mkForce "lsd";
      "ll" = lib.mkForce "lsd -alh";
      "tree" = lib.mkForce "lsd --tree";
    };

    # better find
    programs = {
      fd = {
        enable = true;
        ignores = [ ".git/" ];
      };
      ripgrep.enable = true;
    };

    # TUI file explorer
    programs.yazi.enable = true;

    programs.starship.enable = true;

    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };

    home.packages = lib.mkMerge [
      [
        pkgs.dust # better du
        pkgs.duf # better df
      ]
    ];
  };
}
