{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.macos-defaults;
in
{
  imports = [ ];

  options.custom.macos-defaults = {
    enable = lib.mkEnableOption "set sane macos defaults";
    dock-apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    dock-dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    system.defaults.dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      expose-animation-duration = 0.2;

      launchanim = false;
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;

      persistent-apps = cfg.dock-apps;
      persistent-others = cfg.dock-dirs;

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
      QuitMenuItem = true;
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

      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

      NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false; # false by default - enforce anyways

      WindowManager.EnableStandardClickToShowDesktop = false;

      controlcenter.BatteryShowPercentage = true;
      controlcenter.NowPlaying = true;
      controlcenter.Sound = true;
    };
  };
}
