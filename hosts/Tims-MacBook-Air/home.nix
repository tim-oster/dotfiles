{
  pkgs,
  lib,
  outputs,
  ...
}:
let
  # TODO move somewhere else
  # ref: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/ka/karabiner-elements/package.nix#L63
  walkingpadController = pkgs.buildGoModule {
    pname = "walkingpad";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "tim-oster";
      repo = "walkingpad";
      rev = "fd95d34";
      sha256 = "sha256-SpuPrwM4xJ71EDAPtEc8jZh0kLPAFI7OVJhkG8A9o9k=";
    };

    vendorHash = "sha256-ouzFyGdJtqYssP5l0wqREToiHQctMHtpux+eJyhFG5k=";

    nativeBuildInputs = with pkgs; [
      create-dmg
    ];

    postInstall = ''
      APP_NAME="WalkingPad Controller"
      BUNDLE_ID="dev.timoster.walkingpad-controller"
      APP_DIR="$out/$APP_NAME.app"
      DMG_NAME="$APP_NAME.dmg"
      STAGING_DIR="$out/dmg_staging"

      # Create the .app bundle structure
      mkdir -p "$APP_DIR/Contents/MacOS"
      mkdir -p "$APP_DIR/Contents/Resources"
      echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

      # Copy binary into the app bundle
      cp $out/bin/walkingpad "$APP_DIR/Contents/MacOS/$APP_NAME"
      rm -rf $out/bin

      # Add an Info.plist file
      cat > "$APP_DIR/Contents/Info.plist" <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>CFBundleExecutable</key>
          <string>$APP_NAME</string>
          <key>CFBundleIdentifier</key>
          <string>$BUNDLE_ID</string>
          <key>CFBundleName</key>
          <string>$APP_NAME</string>
          <key>CFBundleVersion</key>
          <string>1.0</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>LSUIElement</key>
          <true/>
          <key>NSBluetoothAlwaysUsageDescription</key>
          <string>Used to connect to Walking Pads.</string>
          <key>NSBluetoothPeripheralUsageDescription</key>
          <string>Used to connect to Walking Pads.</string>
      </dict>
      </plist>
      EOF

      # Prepare the DMG staging directory
      mkdir -p "$STAGING_DIR"
      cp -R "$APP_DIR" "$STAGING_DIR"

      # Create a symbolic link to the Applications folder
      ln -s /Applications "$STAGING_DIR/Applications"

      # Create the DMG file
      create-dmg -volname "$APP_NAME Installer" "$out/$DMG_NAME" "$STAGING_DIR"

      # Cleanup
      rm -rf "$STAGING_DIR"
      rm -rf "$APP_DIR"
    '';
  };
in
{
  imports = builtins.attrValues outputs.homeManagerModules ++ [ ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.11";

    packages = with pkgs; [
      google-chrome
      obsidian
      neofetch
      gimp
      # walkingpadController # TODO
      choose-gui
    ];
  };

  programs = {
    # apply stylix to neovim as well
    neovim.enable = true;

    git = {
      enable = true;
      userName = "tim-oster";
      userEmail = "tim.oster99@gmail.com";
      ignores = [
        "/.direnv*"
        "/.devenv*"
        ".aider*"
      ];
    };

    aerospace = {
      enable = true;

      userSettings = {
        start-at-login = true;

        accordion-padding = 30;

        enable-normalization-flatten-containers = false;
        enable-normalization-opposite-orientation-for-nested-containers = false;

        automatically-unhide-macos-hidden-apps = true;

        gaps =
          let
            margin = 4;
            padding = 4;
          in
          {
            outer.left = margin;
            outer.bottom = margin;
            outer.top = margin;
            outer.right = margin;
            inner.horizontal = padding;
            inner.vertical = padding;
          };

        mode.main.binding = {
          ctrl-alt-enter = "exec-and-forget open -n ${pkgs.alacritty}/Applications/Alacritty.app";
          ctrl-alt-d =
            let
              script = pkgs.writeShellScriptBin "mac-app-picker" ''
                apps=$(${lib.getExe pkgs.fd} --follow --max-depth=1 --glob "*.app" /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ ~/Applications/Home\ Manager\ Apps/)
                selected_index=$(printf "%s\n" "$apps" | sed -E 's/^(\/([^\/])+)+\/(.+)\.app\/?$/\3/g' | ${lib.getExe pkgs.choose-gui} -i)

                if [[ $selected_index != -1 ]]; then
                  app_path=$(printf "%s\n" "$apps" | sed -n "$((selected_index + 1))p")
                  open -n "$app_path"
                fi
              '';
            in
            "exec-and-forget ${lib.getExe script}";

          ctrl-alt-left = "focus --boundaries-action wrap-around-the-workspace left";
          ctrl-alt-down = "focus --boundaries-action wrap-around-the-workspace down";
          ctrl-alt-up = "focus --boundaries-action wrap-around-the-workspace up";
          ctrl-alt-right = "focus --boundaries-action wrap-around-the-workspace right";

          ctrl-alt-shift-left = "move left";
          ctrl-alt-shift-down = "move down";
          ctrl-alt-shift-up = "move up";
          ctrl-alt-shift-right = "move right";

          ctrl-alt-h = "split horizontal";
          ctrl-alt-shift-v = "split vertical";

          ctrl-alt-f = "fullscreen";

          ctrl-alt-s = "layout v_accordion"; # "layout stacking" in i3
          ctrl-alt-w = "layout h_accordion"; # "layout tabbed" in i3
          ctrl-alt-e = "layout tiles horizontal vertical"; # "layout toggle split" in i3
          ctrl-alt-shift-space = "layout floating tiling"; # "floating toggle" in i3
          ctrl-alt-shift-q = "close";

          ctrl-alt-1 = "workspace 1";
          ctrl-alt-2 = "workspace 2";
          ctrl-alt-3 = "workspace 3";
          ctrl-alt-4 = "workspace 4";
          ctrl-alt-5 = "workspace 5";
          ctrl-alt-6 = "workspace 6";
          ctrl-alt-7 = "workspace 7";
          ctrl-alt-8 = "workspace 8";
          ctrl-alt-9 = "workspace 9";
          ctrl-alt-0 = "workspace 10";

          ctrl-alt-shift-1 = "move-node-to-workspace 1";
          ctrl-alt-shift-2 = "move-node-to-workspace 2";
          ctrl-alt-shift-3 = "move-node-to-workspace 3";
          ctrl-alt-shift-4 = "move-node-to-workspace 4";
          ctrl-alt-shift-5 = "move-node-to-workspace 5";
          ctrl-alt-shift-6 = "move-node-to-workspace 6";
          ctrl-alt-shift-7 = "move-node-to-workspace 7";
          ctrl-alt-shift-8 = "move-node-to-workspace 8";
          ctrl-alt-shift-9 = "move-node-to-workspace 9";
          ctrl-alt-shift-0 = "move-node-to-workspace 10";

          ctrl-alt-r = "mode resize";
        };

        mode.resize.binding = {
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          enter = "mode main";
          esc = "mode main";
        };
      };
    };
  };

  custom = {
    stylix = {
      enable = true;
      fontSize = 12;
    };
    terminal.enable = true;
    devenv.enable = true;

    helix = {
      enable = true;
      defaultEditor = true;
    };
    cursor.enable = true;

    _1password = {
      enable = true;
      # 1password item: GitHub Workstation
      gpgSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };
  };
}
