{ config, pkgs, lib, ... }:

{
  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    google-chrome
    obsidian
    i3lock-fancy-rapid
  ];

  nixpkgs.config.allowUnfree = true;

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # envvars available in home manager managed shells
  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
  
  services.gnome-keyring.enable = true;
  services.ssh-agent.enable = true;

  stylix.enable = true;
  stylix.cursor.size = 10;
  # stylix.cursor.package = pkgs.bibata-cursors;
  # stylix.cursor.name = "Bibata-Modern-Ice";
  stylix.fonts.sizes = let size = 10; in {
    applications = size;
    desktop = size;
    popups = size;
    terminal = size;
  };

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
  };

  programs.neovim.enable = true;
  programs.helix.enable = true;
  programs.alacritty.enable = true;

  programs.btop = {
    enable = true;
    settings.vim_keys = true;
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = "Mod4";

      startup = [
        { command = "i3-msg workspace 1"; always = false; notification = false; }
        { command = "${lib.getExe pkgs._1password-gui} --silent"; always = false; notification = true; }
      ];

      keybindings = let modifier = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${lib.getExe pkgs.alacritty}";
        "${modifier}+d" = "exec ${lib.getExe pkgs.rofi} -show run";
        "${modifier}+Shift+x" = "exec ${lib.getExe pkgs.i3lock-fancy-rapid} 5 5";
      };
    };
  };

  programs.rofi.enable = true;

  programs.fzf = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  programs.bat.enable = true;

  home.shell.enableShellIntegration = true;
  programs.direnv.enable = true;

  programs.git = {
    enable = true;
    userName = "tim-oster";
    userEmail = "tim.oster99@gmail.com";
    extraConfig = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      commit.gpgsign = true;
      # 1password item: GitHub Workstation
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };

    delta = {
      enable = true;
      options.side-by-side = true;
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };
}
