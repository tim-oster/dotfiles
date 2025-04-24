{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
{
  imports =
    builtins.attrValues outputs.darwinModules
    ++ builtins.attrValues outputs.sharedModules
    ++ [
      inputs.home-manager.darwinModules.default
      inputs.stylix.darwinModules.stylix
    ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.optimise.automatic = true;
  # needed for devenv
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  # auto apply new settings without having to logout and login
  system.activationScripts.postUserActivation.text = lib.mkAfter ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # needed to support setting a custom shell
  users.knownUsers = [ "timoster" ];
  users.users.timoster = {
    uid = 501;
    name = "timoster";
    home = "/Users/timoster";
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "timoster" = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      neovim
      just
    ];
    shells = [ pkgs.fish ];
  };

  custom = {
    stylix = {
      enable = true;
      theme = "gruvbox-dark-medium";
    };

    podman.enable = true;
    win-keyboard.enable = true;

    macos-defaults = {
      enable = true;
      dock-apps = [
        "/System/Applications/Launchpad.app"
        "${pkgs.google-chrome}/Applications/Google Chrome.app"
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "${pkgs.obsidian}/Applications/Obsidian.app"
        "/System/Applications/System Settings.app"
      ];
      dock-dirs = [
        "/Users/timoster"
        "/Users/timoster/Downloads"
      ];
    };
  };

  homebrew = {
    enable = true;
    brews = [ ];
    casks = [
      "1password"
      "1password-cli"
      "karabiner-elements"
    ];
    taps = [ ];
    masApps = {
      "Final Cut Pro" = 424389933;
      "Compressor" = 424390742;
      "Luminar Neo" = 1584373150;
    };

    # enforce that no versions are updated automatically
    global.autoUpdate = false;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    onActivation.cleanup = "zap"; # aggressively removes all non-nix-managed formulae
  };
}
