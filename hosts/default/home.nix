{ config, pkgs, lib, ... }:

{
  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    helix
    kitty
    google-chrome
    wget
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

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = "Mod4";

      startup = [
        { command = "${lib.getExe pkgs._1password-gui} --silent"; always = false; notification = false; }
      ];

      keybindings = let modifier = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
        "${modifier}+Return" = "exec kitty";
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

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
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };
}
