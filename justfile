switch:
    sudo nixos-rebuild switch --flake ~/dev/dotfiles/#default

cleanup:
    nix-env --delete-generations 7d
    nix-collect-garbage -d
