switch:
    sudo nixos-rebuild switch --flake ~/dev/dotfiles/#default

update:
    nix-flake update
    
cleanup:
    nix-env --delete-generations 7d
    nix-collect-garbage -d
