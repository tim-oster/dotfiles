{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.stylix.nixosModules.stylix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  stylix =
    let
      theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    in
    {
      enable = true;
      polarity = "dark";
      base16Scheme = theme;
      image = pkgs.runCommand "image.png" { } ''
        COLOR=$(${lib.getExe pkgs.yq} -r .palette.base00 ${theme})
        ${lib.getExe pkgs.imagemagick} -size 10x10 xc:$COLOR $out
      '';
      imageScalingMode = "tile";
    };

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.extraPackages = [ ];
  services.xserver.xkb.layout = "de";

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.enable = false;
  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = true;
    user = "tim";
    extraConfig = ''
      [greeter]
      show-password-label = true
      password-label-text = Password
      invalid-password-text = Access Denied
      show-input-cursor = false
      password-alignment = left
      password-input-width = 40

      [greeter-theme]
      font = Sans
      font-size = 1em
      font-weight = normal
      font-style = normal
      background-image = ""
      password-border-width = 0
      password-border-radius = 0

      background-color = #${config.lib.stylix.colors.base00}
      text-color = #${config.lib.stylix.colors.base06}
      error-color = #${config.lib.stylix.colors.base08}
      window-color = #${config.lib.stylix.colors.base02}
      border-color = #${config.lib.stylix.colors.base02}
      border-width = 0px

      password-color = #${config.lib.stylix.colors.base06}
      password-background-color = #${config.lib.stylix.colors.base03}
      password-border-color = #${config.lib.stylix.colors.base03}
    '';
  };
  services.xserver.displayManager.lightdm.extraSeatDefaults = ''
    user-session = none+i3
  '';
  services.xserver.resolutions = [
    {
      x = 5120;
      y = 1440;
    }
  ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # needed for redshift
  services.geoclue2.enable = true;

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.tim = {
    isNormalUser = true;
    description = "tim";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "tim" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "tim" = import ./home.nix;
    };
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.systemPackages = with pkgs; [
    neovim
    libnotify
  ];

  system.stateVersion = "24.11";

  # enable nvidia for wayland (although called xserver) and enable opengl
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  # enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # load open-source nvidia drivers
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
