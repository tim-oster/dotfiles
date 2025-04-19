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
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "${pkgs.obsidian}/Applications/Obsidian.app"
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

  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # do not show special chars on key hold
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  # disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;

  system.defaults = {
    # force 24h format regardless of configured tiemzone
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
    NSGlobalDomain.AppleMetricUnits = 1;
    NSGlobalDomain.AppleTemperatureUnit = "Celsius";

    # TODO couple this to stylix somehow?
    NSGlobalDomain.AppleInterfaceStyle = "Dark";

    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

    NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false; # false by default - enforce anyways

    WindowManager.EnableStandardClickToShowDesktop = false;

    # TODO
    controlcenter.BatteryShowPercentage = true;
    controlcenter.NowPlaying = true;
    controlcenter.Sound = true;
  };

  system.activationScripts.postUserActivation.text = lib.mkAfter ''
    # setup custom keyboard layouts (requires restart)
    sudo rm -f "/Library/Keyboard Layouts/*osx-win-germany.keylayout"
    sudo cp "${../../modules/darwin/osx-win-germany.keylayout}" "/Library/Keyboard Layouts"

    # auto apply new settings without having to logout and login
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # TODO couple with stylix
  # TODO split for podman
  system.activationScripts.extraUserActivation.text = lib.mkAfter ''
    osascript -e 'tell application "System Events" to set picture of every desktop to "${config.stylix.image}"'

    if [[ $(${lib.getExe pkgs.podman} system connection list --format json | jq length) -eq 0 ]]; then
      ${lib.getExe pkgs.podman} machine init podman-machine-default
    fi
  '';

  # TODO required for podman
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    softwareupdate --install-rosetta --agree-to-license
  '';

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

    # TODO write brewfile to this repo to lock versions? adjust justfile to cleanup / upgrade versions

    # enforce that no versions are updated automatically
    global.autoUpdate = false;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    onActivation.cleanup = "zap"; # aggressively removes all non-nix-managed formulae
  };
}
