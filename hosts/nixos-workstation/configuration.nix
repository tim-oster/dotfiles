{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports =
    builtins.attrValues outputs.nixosModules
    ++ builtins.attrValues outputs.sharedModules
    ++ [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  # needed for devenv
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  system.stateVersion = "24.11";

  networking.hostName = "nixos-workstation";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.tim = {
    isNormalUser = true;
    description = "tim";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };
  users.groups.dialout = {
    members = [ "tim" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "tim" = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "tim" ];
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
  };

  custom.stylix = {
    enable = true;
    theme = "gruvbox-dark-medium";
  };

  custom.oryx = {
    enable = true;
    groupMembers = [ "tim" ];
  };

  custom.vial = {
    enable = true;
    groupMembers = [ "tim" ];
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
