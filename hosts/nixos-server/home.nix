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

  virtualisation.quadlet.autoEscape = true; # TODO ?
  virtualisation.quadlet.networks.proxy = {
    networkConfig = {
      name = "proxy";
    };
  };
  virtualisation.quadlet.containers.traefik = {
    autoStart = true;
    containerConfig = {
      image = "traefik:latest";
      name = "traefik";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      publishPorts = [
        "80:80"
        "443:443"
      ];
      volumes = [
        "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro"
        "${./docker/traefik/certs}:/certs:ro" # TODO
        "${./docker/traefik/tls.yaml}:/dynamic/tls.yaml"
      ];
      exec = [
        # EntryPoints
        "--entrypoints.http.address=:80"
        "--entrypoints.http.http.redirections.entrypoint.to=https"
        "--entrypoints.http.http.redirections.entrypoint.scheme=https"
        "--entrypoints.http.http.redirections.entrypoint.permanent=true"
        "--entrypoints.https.address=:443"
        "--entrypoints.https.http.tls=true"

        # Attach the static configuration tls.yaml file that contains the tls configuration settings
        "--providers.file.filename=/dynamic/tls.yaml"
        # TODO https://doc.traefik.io/traefik/setup/docker/#tls-certificate-management-lets-encrypt

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
        "traefik.http.routers.dashboard.rule=Host(`traefik.server.home`)"
        "traefik.http.routers.dashboard.entrypoints=https"
        "traefik.http.routers.dashboard.service=api@internal"
        "traefik.http.routers.dashboard.tls=true"

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
  virtualisation.quadlet.containers.glance = {
    autoStart = true;
    containerConfig = {
      image = "glanceapp/glance";
      name = "glance";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      volumes = [
        "${./docker/glance/config}:/app/config:ro"
        "/mnt/nasdata:/mnt/nasdata:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.glance.entrypoints=https"
        "traefik.http.routers.glance.rule=Host(`start.server.home`)"
        "traefik.http.routers.glance.tls=true"
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
      image = "corentinth/it-tools:latest";
      name = "ittools";
      noNewPrivileges = true;
      networks = [ "proxy" ];
      labels = [
        "traefik.enable=true"
        "traefik.docker.network=proxy"
        "traefik.http.routers.ittools.entrypoints=https"
        "traefik.http.routers.ittools.rule=Host(`ittools.server.home`)"
        "traefik.http.routers.ittools.tls=true"
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
      image = "portainer/portainer-ce:latest";
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
        "traefik.http.routers.portainer.rule=Host(`portainer.server.home`)"
        "traefik.http.routers.portainer.tls=true"
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
}
