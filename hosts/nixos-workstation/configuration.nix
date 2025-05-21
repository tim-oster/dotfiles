{
  config,
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

  networking.hostName = "nixos-workstation";
  networking.networkmanager.enable = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/9d75b42d-76dd-47db-9ac8-4b3ea77826c6";
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
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

  custom.locale.enable = true;

  custom.xserver = {
    enable = true;
    displayWidth = 5120;
    displayHeight = 1440;
    useStylix = true;
    videoDriver = "nvidia";
    autoLoginUser = username;
  };

  custom.stylix = {
    enable = true;
    theme = "gruvbox-dark-medium";
  };

  custom.oryx = {
    enable = true;
    groupMembers = [ username ];
  };

  custom.vial = {
    enable = true;
    groupMembers = [ username ];
  };

  services = {
    gnome.gnome-keyring.enable = true;
    geoclue2.enable = true;
    printing.enable = true;
    blueman.enable = true;
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security = {
    rtkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    nvidia-container-toolkit.enable = true;
  };
}
