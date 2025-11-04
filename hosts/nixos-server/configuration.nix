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
      inputs.quadlet-nix.nixosModules.quadlet
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
    initrd.luks.devices = {
      # root partition (nvme1)
      "luks-fafb569c-0a09-4773-8391-a947e08db2dd".device =
        "/dev/disk/by-uuid/fafb569c-0a09-4773-8391-a947e08db2dd";

      # swap partition (nvme1)
      "luks-1aa6aca7-730a-4858-9cdb-581208c8b2c1".device =
        "/dev/disk/by-uuid/1aa6aca7-730a-4858-9cdb-581208c8b2c1";

      # data raid (nvme0)
      "nvme0n1_crypt".device = "/dev/disk/by-uuid/ab13146f-d3c6-416f-b986-113e1e3c3170";

      # data raid (nvme2)
      "nvme2n1_crypt".device = "/dev/disk/by-uuid/58727499-7b80-41e0-9d10-e1b2f81239e1";
    };
    kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80; # allow podman to expose port 80
    };
  };

  users.users = {
    "${username}" = {
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
      linger = true; # required for auto start before user login
      autoSubUidGidRange = true; # required for rootless container with multiple users
    };

    github-runner = {
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

    nasvault = {
      isSystemUser = true;
      description = "User owns vault directory on NAS + facilitates SMB";
      home = "/var/lib/nasvault";
      createHome = true;
      group = "nasvault";
      shell = pkgs.bashInteractive;
    };
  };

  users.groups = {
    github-runner = { };
    nasvault = { };
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
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PODMAN_COMPOSE_WARNING_LOGS = "false"; # supress podman-compose related warning
    };
    systemPackages = with pkgs; [
      neovim
      just
      podman-compose
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
    quadlet.enable = true;

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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # traefik ports
      80
      443
      # other ports are added via openFirewall options
    ];
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

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nasvault";
        "netbios name" = "nasvault";
        "security" = "user";
        "hosts allow" = "10.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      # use `sudo smbpasswd -a nasvault` to configure password
      nasvault = {
        "path" = "/mnt/nasdata/vault";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0660";
        "directory mask" = "0770";
        "valid users" = "nasvault";
      };
    };
  };
}
