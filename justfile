switch:
    #!/bin/sh
    if [[ "{{ os() }}" == "linux" ]]; then
        sudo nixos-rebuild switch --flake "{{ justfile_directory() }}" --show-trace --print-build-logs --verbose
    elif [[ "{{ os() }}" == "macos" ]]; then
        # This could use `darwin-rebuild switch` directly but uses `nix run` instead to support bootstrapping on first execution on new machines.
        # The same goes for the experiemental features flag, which is globally configured after the first switch.
        nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --flake "{{ justfile_directory() }}" --show-trace --print-build-logs --verbose
    else
        echo "Unsupported OS {{ os() }}"
        exit 1
    fi

update:
    nix flake update
    
cleanup:
    nix-env --delete-generations 7d
    nix-collect-garbage -d
