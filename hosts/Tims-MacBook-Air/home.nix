{
  pkgs,
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
      gimp
      # walkingpadController # TODO
      choose-gui
    ];
  };

  custom = {
    shared.enable = true;
    stylix.fontSize = 12;

    aerospace = {
      enable = true;
      terminal = "${pkgs.alacritty}/Applications/Alacritty.app";
    };

    karabiner-config.enable = true;
  };
}
