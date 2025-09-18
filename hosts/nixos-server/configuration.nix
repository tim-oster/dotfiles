{
  pkgs,
  inputs,
  outputs,
  ...
}:

let
  username = "server";
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
      trusted-users = [
        "root"
        "github-runner"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  system.stateVersion = "25.05";

  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd.luks.devices."luks-1aa6aca7-730a-4858-9cdb-581208c8b2c1".device =
      "/dev/disk/by-uuid/1aa6aca7-730a-4858-9cdb-581208c8b2c1";
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "podman"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H workstation"
    ];
    shell = pkgs.fish;
  };

  users.users.github-runner = {
    isSystemUser = true;
    home = "/var/lib/github-runner";
    createHome = true;
    group = "github-runner";
    extraGroups = [
      "nixbld"
      "podman"
      "docker"
    ];
    shell = pkgs.bashInteractive;
  };
  users.groups.github-runner = { };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "${username}" = import ./home.nix;
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
  };

  custom = {
    locale.enable = true;

    stylix = {
      enable = true;
      theme = "gruvbox-dark-medium";
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

  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-routes=false"
      "--advertise-routes=10.0.0.0/16"
    ];
    useRoutingFeatures = "both";
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  # if it magically breaks again:
  # - try debugging with this: dmesg -T | egrep -i 'seccomp|audit.*syscall'
  # - last resort: install dependencies in nix store "manually" to avoid them being fetched from within the runner
  services.github-runners = {
    neowire-runner1 = {
      enable = true;
      name = "runner1";
      user = "github-runner";
      tokenFile = "/secrets/gh-runner1-token";
      url = "https://github.com/neowire-gmbh";
      extraPackages = with pkgs; [
        docker
      ];
      extraEnvironment = {
        NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos";
        HOME = "/var/lib/github-runner/neowire-runner1";
        XDG_CACHE_HOME = "/var/lib/github-runner/neowire-runner1/.cache";
      };
      serviceOverrides = {
        BindPaths = [ "/var/run/docker.sock" ];
      };
    };
  };
}
