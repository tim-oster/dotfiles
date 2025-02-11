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

  programs.autorandr = {
    enable = true;
    
    hooks.postswitch."notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
    #hooks.postswitch."change-background" = readFile ./change-background.sh;

    profiles.default = {
      fingerprint = {
        "DP-0" = "00ffffffffffff004c2d9c0f000000002b1c0104b57722783ba2a1ad4f46a7240e5054bfef80714f810081c08180a9c0b3009500d1c074d600a0f038404030203a00a9504100001a000000fd003078bebe61010a202020202020000000fc00433439524739780a2020202020000000ff004831414b3530303030300a202002ce02032cf046105a405b3f5c2309070783010000e305c0006d1a0000020f307800048b127317e60605018b7312565e00a0a0a0295030203500a9504100001a584d00b8a1381440f82c4500a9504100001e1a6800a0f0381f4030203a00a9504100001af4b000a0f038354030203a00a9504100001a0000000000000000000000af701279000003013c57790188ff139f002f801f009f055400020009006c370108ff139f002f801f009f0545000200090033b70008ff139f002f801f009f0528000200090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f390";
      };
      config = {
        "DP-0" = {
          enable = true;
	  primary = true;
	  mode = "5120x1440";
	  rate = "119.97";
	};
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = "Mod4";

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
