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

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
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
