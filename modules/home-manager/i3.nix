{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.i3;
in
{
  imports = [ ];

  options.custom.i3 = {
    enable = lib.mkEnableOption "i3 config";
    startup = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    terminal = lib.mkOption {
      type = lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        modifier = "Mod4";

        bars = [
          (
            (if config.lib.stylix != null then config.lib.stylix.i3.bar else { })
            // {
              position = "bottom";
              statusCommand = "${lib.getExe pkgs.i3status-rust} config-default.toml";
            }
          )
        ];

        startup = [
          {
            command = "i3-msg workspace 1";
            always = false;
            notification = false;
          }
          {
            command = "xset r rate 200 40";
            always = true;
            notification = false;
          }
          {
            command = "xset -dpms && xset s off"; # disable DPMS and screen blanking
            always = true;
            notification = false;
          }
        ]
        ++ (map (cmd: {
          command = cmd;
          always = false;
          notification = false;
        }) cfg.startup);

        modes.resize =
          let
            inc = 5;
          in
          {
            Up = "resize shrink height ${toString inc} px or ${toString inc} ppt";
            Down = "resize grow height ${toString inc} px or ${toString inc} ppt";
            Left = "resize shrink width ${toString inc} px or ${toString inc} ppt";
            Right = "resize grow width ${toString inc} px or ${toString inc} ppt";
            Escape = "mode default";
            Return = "mode default";
          };

        keybindings =
          let
            modifier = config.xsession.windowManager.i3.config.modifier;
          in
          lib.mkOptionDefault {
            "${modifier}+Return" = "exec ${lib.getExe cfg.terminal}";
            "${modifier}+d" = "exec ${lib.getExe pkgs.rofi} -show run";
            "${modifier}+Shift+x" = "exec ${lib.getExe pkgs.i3lock-fancy-rapid} 5 5";
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";
            "${modifier}+shift+h" = "move left";
            "${modifier}+shift+j" = "move down";
            "${modifier}+shift+k" = "move up";
            "${modifier}+shift+l" = "move right";
            "${modifier}+b" = "split horizontal";
            "XF86AudioMute" = "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer -q set Master 5%- unmute";
            "XF86AudioRaiseVolume" =
              "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer -q set Master 5%+ unmute";
            "XF86AudioMicMute" = "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
          };
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars.default = {
        settings = lib.mkIf (config.lib.stylix != null) {
          theme.overrides = config.lib.stylix.i3status-rust.bar;
        };
        blocks = [
          {
            block = "cpu";
          }
          {
            block = "load";
            format = " $icon $1m.eng(w:4) ";
          }
          {
            block = "memory";
            format = " $icon $mem_total_used.eng(w:3) / $mem_total ";
            format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
          }
          {
            block = "temperature";
          }
          {
            block = "disk_space";
            alert = 10.0;
            format = " $icon $available.eng(w:2) ";
            info_type = "available";
            interval = 20;
            path = "/";
            warning = 20.0;
          }
          {
            block = "nvidia_gpu";
            if_command = "type -P nvidia-smi";
          }
          {
            block = "net";
            device = "^enp.+$";
            format = " ^icon_net_wired $ip ";
            format_alt = " ^icon_net_wired $ipv6 ";
            missing_format = " ^icon_net_wired × ";
          }
          {
            block = "net";
            device = "^wlp.+$";
            format = " ^icon_net_wireless $ip - $ssid ";
            format_alt = " ^icon_net_wireless $ipv6 ";
            missing_format = " ^icon_net_wireless × ";
          }
          (
            let
              format = " $icon $percentage {$time_remaining.dur(hms:true, min_unit:m) |} ";
            in
            {
              block = "battery";
              if_command = "ls /sys/class/power_supply/ | grep -q \"^BAT\"";
              format = format;
              full_format = format;
              charging_format = format;
              empty_format = format;
              not_charging_format = format;
              info = 40;
              good = 40;
              warning = 30;
            }
          )
          {
            block = "sound";
            click = [
              {
                button = "left";
                cmd = "pavucontrol";
              }
            ];
          }
          {
            block = "time";
            format = " $timestamp.datetime(f:'%a %F %T %Z')";
            interval = 5;
          }
        ];
      };
    };

    programs.rofi.enable = true;
    services.dunst.enable = true;
  };
}
