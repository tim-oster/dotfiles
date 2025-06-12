switch:
    #!/bin/sh
    if [[ "{{ os() }}" == "linux" ]]; then
        sudo nixos-rebuild switch --flake "{{ justfile_directory() }}" --show-trace --print-build-logs --verbose
    elif [[ "{{ os() }}" == "macos" ]]; then
        if ! [ -x "$(command -v darwin-rebuild)" ]; then
            # required for first time bootstrapping
            sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --flake "{{ justfile_directory() }}" --show-trace --print-build-logs --verbose
        else
            sudo darwin-rebuild switch --flake "{{ justfile_directory() }}" --show-trace --print-build-logs --verbose
        fi
    else
        echo "Unsupported OS {{ os() }}"
        exit 1
    fi

update:
    nix flake update
    
cleanup:
    nix-env --delete-generations 7d
    nix-collect-garbage -d
