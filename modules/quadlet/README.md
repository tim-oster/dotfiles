# podman quadlet

This directory contains all podman quadlets for the homelab. The containers are run using podman quadlets to enable rootless execution as user systemd units.
By enabling lingering, the containers are started on boot and can keep on running without the user needing to be logged in.

## Resources

- https://github.com/JamesTurland/JimsGarage/tree/main
- https://github.com/Tarow/nix-podman-stacks
- https://github.com/Keyruu/shinyflakes/tree/main/nix/hosts/mentat/modules/stacks
