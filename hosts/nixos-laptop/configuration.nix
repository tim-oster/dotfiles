{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:

let
  username = "tim";
in
{
  imports =
    builtins.attrValues outputs.nixosModules
    ++ builtins.attrValues outputs.sharedModules
    ++ [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    # needed for devenv
    extraOptions = ''
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };

  system.stateVersion = "24.11";

  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    initrd.luks.devices."luks-51b05874-d903-41bf-8589-a1a1635efadd".device =
      "/dev/disk/by-uuid/51b05874-d903-41bf-8589-a1a1635efadd";
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video" # required to control display brightness
      "podman"
    ];
    shell = pkgs.fish;
  };
  users.groups.dialout = {
    members = [ username ];
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "${username}" = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };

    # required for controlling display brightness with fn keys
    light = {
      enable = true;
      brightnessKeys.enable = true;
    };

    # ensure suspend and hibernation lock the screen
    xss-lock = {
      enable = true;
      lockerCommand = "${lib.getExe pkgs.i3lock-fancy-rapid} 5 5";
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      neovim
      libnotify
      just
    ];
  };

  custom = {
    locale.enable = true;

    xserver = {
      enable = true;
      displayWidth = 1920;
      displayHeight = 1080;
      useStylix = true;
      autoLoginUser = username;
    };

    stylix = {
      enable = true;
      theme = "gruvbox-dark-medium";
    };

    oryx = {
      enable = true;
      groupMembers = [ username ];
    };

    vial = {
      enable = true;
      groupMembers = [ username ];
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
    blueman.enable = true;
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # handle powerbutton and lid close events
    logind = {
      powerKey = "suspend-then-hibernate";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend-then-hibernate";
    };
  };

  # configure hibernation deplay after suspension
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';

  security = {
    rtkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;
    # required to allow i3lock to verify the user's password
    pam.services.i3lock.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics.enable = true;
  };
}
