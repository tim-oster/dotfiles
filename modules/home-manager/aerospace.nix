{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.aerospace;
in
{
  imports = [ ];

  options.custom.aerospace = {
    enable = lib.mkEnableOption "aerospace config";
    terminal = lib.mkOption {
      type = lib.types.string;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.aerospace = {
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
          ctrl-alt-enter = "exec-and-forget open -n ${cfg.terminal}";
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
          ctrl-alt-v = "split vertical";

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

        mode.resize.binding =
          let
            inc = 50;
          in
          {
            left = "resize width -${toString inc}";
            up = "resize height +${toString inc}";
            down = "resize height -${toString inc}";
            right = "resize width +${toString inc}";
            enter = "mode main";
            esc = "mode main";
          };

        on-window-detected = [
          {
            "if".workspace = "2";
            run = [ "layout floating" ];
          }
        ];
      };
    };
  };
}
