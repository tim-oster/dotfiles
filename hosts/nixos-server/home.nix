{
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [
    inputs.quadlet-nix.homeManagerModules.quadlet
  ];

  programs.home-manager.enable = true;

  home = {
    username = "server";
    homeDirectory = "/home/server";
    stateVersion = "24.11";
    packages = with pkgs; [
      tmux
    ];
  };

  custom = {
    stylix.enable = true;
    terminal.enable = true;
    devenv.enable = true;

    git = {
      enable = true;
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };
  };

  virtualisation.quadlet = {
    autoEscape = true;
    autoUpdate = {
      enable = true;
      calendar = "*-*-* 04:00:00";
    };
  };
  virtualisation.quadlet.networks.proxy = {
    networkConfig = {
      name = "proxy";
    };
  };
  virtualisation.quadlet.containers.traefik = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/traefik:latest";
      autoUpdate = "registry";
      name = "traefik";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      publishPorts = [
        "80:80"
        "443:443"
      ];
      volumes = [
        "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro"
        "traefik_letsencrypt_data:/letsencrypt"
      ];
      environments = {
        "CF_DNS_API_TOKEN" = "bX8VtxpApBMmp5KIcA_Vd-cH_ky0xwdbiGsF1lCS";
      };
      exec = [
        # EntryPoints
        "--entrypoints.http.address=:80"
        "--entrypoints.http.http.redirections.entrypoint.to=https"
        "--entrypoints.http.http.redirections.entrypoint.scheme=https"
        "--entrypoints.http.http.redirections.entrypoint.permanent=true"
        "--entrypoints.https.address=:443"
        "--entrypoints.https.http.tls=true"
        "--entrypoints.https.http.tls.certresolver=cloudflare"

        # letsencrypt
        "--certificatesresolvers.cloudflare.acme.email=admin@timoster.dev"
        "--certificatesresolvers.cloudflare.acme.storage=/letsencrypt/acme.json"
        "--certificatesresolvers.cloudflare.acme.dnschallenge.provider=cloudflare"

        # Providers
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--providers.docker.network=proxy"

        # API & Dashboard
        "--api.dashboard=true"
        "--api.insecure=false"

        # Observability
        "--log.level=INFO"
        "--accesslog=true"
      ];
      labels = [
        # Enable self‑routing
        "traefik.enable=true"

        # Dashboard router
        "traefik.http.routers.dashboard.rule=Host(`traefik-hl.timoster.dev`)"
        "traefik.http.routers.dashboard.entrypoints=https"
        "traefik.http.routers.dashboard.tls=true"
        "traefik.http.routers.dashboard.tls.certresolver=cloudflare"
        "traefik.http.routers.dashboard.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.dashboard.service=api@internal"

        # Basic‑auth middleware
        (
          "traefik.http.middlewares.dashboard-auth.basicauth.users=admin:"
          + ''$$apr1$$XPRzG6ZB$$b/tM0mp97kAknrE1JBUvq1''
        )
        "traefik.http.routers.dashboard.middlewares=dashboard-auth@docker"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.volumes.traefikLetsencryptData = {
    volumeConfig = {
      name = "traefik_letsencrypt_data";
    };
  };
  virtualisation.quadlet.containers.glance = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/glanceapp/glance:latest";
      name = "glance";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      volumes = [
        "${./../../modules/quadlet/glance/config}:/app/config:ro"
        "/mnt/nasdata:/mnt/nasdata:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.glance.rule=Host(`hl.timoster.dev`)"
        "traefik.http.routers.glance.entrypoints=https"
        "traefik.http.routers.glance.tls=true"
        "traefik.http.routers.glance.tls.certresolver=cloudflare"
        "traefik.http.routers.glance.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.glance.service=glance"
        "traefik.http.services.glance.loadbalancer.server.port=8080"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.containers.ittools = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/corentinth/it-tools:latest";
      name = "ittools";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.ittools.entrypoints=https"
        "traefik.http.routers.ittools.rule=Host(`ittools-hl.timoster.dev`)"
        "traefik.http.routers.ittools.tls=true"
        "traefik.http.routers.ittools.tls.certresolver=cloudflare"
        "traefik.http.routers.ittools.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.ittools.service=ittools"
        "traefik.http.services.ittools.loadbalancer.server.port=80"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.containers.portainer = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/portainer/portainer-ce:latest";
      name = "portainer";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      volumes = [
        "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
        "portainer_data:/data"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.portainer.entrypoints=https"
        "traefik.http.routers.portainer.rule=Host(`portainer-hl.timoster.dev`)"
        "traefik.http.routers.portainer.tls=true"
        "traefik.http.routers.portainer.tls.certresolver=cloudflare"
        "traefik.http.routers.portainer.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.portainer.service=portainer"
        "traefik.http.services.portainer.loadbalancer.server.port=9000"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.volumes.portainerData = {
    volumeConfig = {
      name = "portainer_data";
    };
  };
  virtualisation.quadlet.containers.adguard = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/adguard/adguardhome:edge";
      autoUpdate = "registry";
      name = "adguard";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      publishPorts = [
        "53:53/tcp"
        "53:53/udp"
        "853:853"
      ];
      volumes = [
        "adguard_conf:/opt/adguardhome/conf"
        "adguard_work:/opt/adguardhome/work"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.adguard.entrypoints=https"
        "traefik.http.routers.adguard.rule=Host(`adguard-hl.timoster.dev`)"
        "traefik.http.routers.adguard.tls=true"
        "traefik.http.routers.adguard.tls.certresolver=cloudflare"
        "traefik.http.routers.adguard.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.adguard.service=adguard"
        "traefik.http.services.adguard.loadbalancer.server.port=3000"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.volumes = {
    adguardConf = {
      volumeConfig = {
        name = "adguard_conf";
      };
    };
    adguardWork = {
      volumeConfig = {
        name = "adguard_work";
      };
    };
  };
  virtualisation.quadlet.containers.backrest = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/garethgeorge/backrest:latest";
      autoUpdate = null; # never auto update
      name = "backrest";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      addGroups = [ "keep-groups" ]; # ensures that nasvault membership is propagated into container
      environments = {
        "BACKREST_DATA" = "/mnt/data";
        "BACKREST_CONFIG" = "/mnt/config/config.json";
      };
      volumes = [
        "backrest:/mnt"
        "/mnt/nasdata:/backup-volumes/nasdata:ro"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.backrest.entrypoints=https"
        "traefik.http.routers.backrest.rule=Host(`backrest-hl.timoster.dev`)"
        "traefik.http.routers.backrest.tls=true"
        "traefik.http.routers.backrest.tls.certresolver=cloudflare"
        "traefik.http.routers.backrest.tls.domains[0].main=*.timoster.dev"
        "traefik.http.routers.backrest.service=backrest"
        "traefik.http.services.backrest.loadbalancer.server.port=9898"
      ];
    };
    serviceConfig = {
      Restart = "unless-stopped";
    };
  };
  virtualisation.quadlet.volumes = {
    backrest = {
      volumeConfig = {
        name = "backrest";
      };
    };
  };
}
