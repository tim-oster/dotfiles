{
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  outputs,
  ...
}:

let
  username = "timoster";
in
{
  imports =
    builtins.attrValues outputs.darwinModules
    ++ builtins.attrValues outputs.sharedModules
    ++ [
      inputs.home-manager.darwinModules.default
      inputs.stylix.darwinModules.stylix
    ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    };
    # needed for devenv
    extraOptions = ''
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = username;

  # auto apply new settings without having to logout and login
  system.activationScripts.postActivation.text = lib.mkAfter ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # needed to support setting a custom shell
  users.knownUsers = [ username ];
  users.users."${username}" = {
    uid = 501;
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs pkgs-unstable; };
    backupFileExtension = "backup";
    users = {
      "${username}" = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
  };

  services.tailscale.enable = true;

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

    podman = {
      enable = true;
      asUser = username;
    };
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
        "/Users/${username}"
        "/Users/${username}/Downloads"
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
      "Photomator" = 1444636541;
      "Xcode" = 497799835;
    };

    # enforce that no versions are updated automatically
    global.autoUpdate = false;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    onActivation.cleanup = "zap"; # aggressively removes all non-nix-managed formulae
  };
}
