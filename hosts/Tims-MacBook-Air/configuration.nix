{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
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

  custom.stylix = {
    enable = true;
    theme = "gruvbox-dark-medium";
  };

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.2;
    expose-animation-duration = 0.2;

    launchanim = false;
    mineffect = "scale";
    minimize-to-application = true;
    mru-spaces = false;

    persistent-apps = [
      "/System/Applications/Launchpad.app"
      "${pkgs.google-chrome}/Applicactions/Google Chrome.app"
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "/System/Applications/System Settings.app"
    ];
    persistent-others = [
      "/Users/timoster"
      "/Users/timoster/Downloads"
    ];

    show-recents = false;
    tilesize = 48;

    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXDefaultSearchScope = "SCcf"; # set search scope to current folder instead of "This Mac"
    FXEnableExtensionChangeWarning = false;
    NewWindowTarget = "Home"; # show home directory in new finder windows
    QuitMenuItem = true; # TODO
    ShowPathbar = true;
    _FXShowPosixPathInTitle = true;
    _FXSortFoldersFirst = true;
    _FXSortFoldersFirstOnDesktop = true;
  };

  system.defaults.loginwindow = {
    DisableConsoleAccess = true;
    GuestEnabled = false;
  };

  system.defaults.screencapture = {
    disable-shadow = true;
    location = "~/Desktop";
    target = "clipboard";
  };

  system.keyboard = {
    enableKeyMapping = true;
  };
  system.activationScripts.keyboard.text =
    let
      device = {
        VendorID = 12951; # 0x3297
        ProductID = 18806; # 0x4976
      };
      # mappings can be generated using this tool: https://hidutil-generator.netlify.app/
      mappings = [
        {
          HIDKeyboardModifierMappingSrc = 30064771296; # left_control
          HIDKeyboardModifierMappingDst = 30064771299; # left_command
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771299; # left_command
          HIDKeyboardModifierMappingDst = 30064771296; # left_control
        }
      ];
    in
    lib.mkAfter ''
      # special remapping for ErgodoxEZ
      hidutil property --matching '${builtins.toJSON device}' --set '{"UserKeyMapping":${builtins.toJSON mappings}}' > /dev/null
    '';

  # TODO go through all options
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.defaults = {
    NSGlobalDomain.AppleICUForce24HourTime = true;
    # TODO couple this to stylix somehow?
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  system.activationScripts.postUserActivation.text = ''
    # setup custom keyboard layouts (requires restart)
    sudo rm -f "/Library/Keyboard Layouts/*osx-win-germany.keylayout"
    sudo cp "${../../modules/darwin/osx-win-germany.keylayout}" "/Library/Keyboard Layouts"

    # auto apply new settings without having to logout and login
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # TODO couple with stylix
  system.activationScripts.extraUserActivation.text = lib.mkAfter ''
    osascript -e 'tell application "System Events" to set picture of every desktop to "${config.stylix.image}"'
  '';
}
