{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    google-chrome
    obsidian
    pavucontrol
    neofetch
    dust # better du
    duf # better df
    delve # go debugger

    (pkgs.writeShellScriptBin "redshift-on" "redshift -P -O 3000")
    (pkgs.writeShellScriptBin "redshift-off" "redshift -x")
    (pkgs.writeShellScriptBin "wifimenu" ''
         #!/usr/bin/env bash
         
         # modified version of: https://github.com/ericmurphyxyz/rofi-wifi-menu

         notify-send "Getting list of available Wi-Fi networks..."
         # Get a list of available wifi connections and morph it into a nice-looking list
         wifi_list=''\$(nmcli -t --fields "SECURITY,SSID" device wifi list | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/ //g" | sed "/--/d" | sed "s/no//" | sed "s/yes/✔/" | sort)

         connected=''\$(nmcli -fields WIFI g)
         if [[ "''\$connected" =~ "enabled" ]]; then
         	toggle="󰖪  Disable Wi-Fi"
         elif [[ "''\$connected" =~ "disabled" ]]; then
         	toggle="󰖩  Enable Wi-Fi"
         fi

         # Use rofi to select wifi network
         chosen_network=''\$(echo -e "''\$toggle\n''\$wifi_list" | uniq --skip-chars=5 | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )
         # Get name of connection
         read -r chosen_id <<< "''\${chosen_network:2}"

         if [ "''\$chosen_network" = "" ]; then
         	exit
         elif [ "''\$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
         	nmcli radio wifi on
         elif [ "''\$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
         	nmcli radio wifi off
         else
           # disconnect if connected
           if [[ $(nmcli -t --fields "ACTIVE,SSID" device wifi list | grep "^yes" | grep ":''\$chosen_id\''\$" | wc -l) -gt 0 ]]; then
             nmcli connection down id "''\$chosen_id"
             notify-send "Connection Closed" "Disconnected from "''\$chosen_id"."
             exit
           fi
         
         	# Message to show when connection is activated successfully
           success_message="You are now connected to the Wi-Fi network \"''\$chosen_id\"."

         	# Get saved connections
         	saved_connections=''\$(nmcli -g NAME connection)
         	if [[ ''\$(echo "''\$saved_connections" | grep -w "''\$chosen_id") = "''\$chosen_id" ]]; then
         		if nmcli connection up id "''\$chosen_id" | grep "successfully"; then
               notify-send "Connection Established" "''\$success_message"
               exit
             fi
           fi

       		if [[ "''\$chosen_network" =~ "" ]]; then
       			wifi_password=''\$(rofi -dmenu -p "Password: " )
       		fi

      		  if nmcli device wifi connect "''\$chosen_id" password "''\$wifi_password" ; then
             notify-send "Connection Established" "''\$success_message"
           else
             notify-send "Connection Failed" "Invalid password"
           fi
         fi
    '')
  ];

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  services.gnome-keyring.enable = true;
  services.ssh-agent.enable = true;

  services.dunst.enable = true;

  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  stylix.enable = true;
  stylix.cursor.size = 8;
  stylix.fonts.sizes =
    let
      size = 10;
    in
    {
      applications = size;
      desktop = size;
      popups = size;
      terminal = size;
    };

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
  };

  programs.neovim.enable = true;
  programs.helix = {
    enable = true;
    defaultEditor = true;
    ignores = [ ".git/" ];
    languages = {
      language-server.nil = {
        command = (lib.getExe pkgs.nil);
      };
      language-server.gopls = {
        command = (lib.getExe pkgs.gopls);
      };
      language-server.golangci-lint-lsp = {
        command = (lib.getExe pkgs.golangci-lint-langserver);
        config.command = [
          (lib.getExe pkgs.golangci-lint)
          "run"
          "--out-format"
          "json"
          "--issues-exit-code=1"
        ];
      };

      language = [
        {
          name = "nix";
          language-servers = [ "nil" ];
          formatter = {
            command = (lib.getExe pkgs.nixfmt-rfc-style);
          };
        }
      ];
    };
    settings = {
      editor = {
        line-number = "relative";
        cursorline = true;
        insert-final-newline = true;

        cursor-shape.insert = "bar";

        indent-guides = {
          render = true;
          skip-levels = 1;
        };

        lsp.display-messages = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";
      };
    };
  };
  programs.alacritty.enable = true;

  programs.btop = {
    enable = true;
    settings.vim_keys = true;
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = "Mod4";

      bars = [
        (
          config.lib.stylix.i3.bar
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
          command = "${lib.getExe pkgs._1password-gui} --silent";
          always = false;
          notification = false;
        }
        {
          command = "${lib.getExe pkgs.networkmanagerapplet}";
          always = false;
          notification = false;
        }
        {
          command = "blueman-applet";
          always = false;
          notification = false;
        } # installed in configuration.nix
      ];

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
          "${modifier}+Return" = "exec ${lib.getExe pkgs.alacritty}";
          "${modifier}+d" = "exec ${lib.getExe pkgs.rofi} -show run";
          "${modifier}+Shift+x" = "exec ${lib.getExe pkgs.i3lock-fancy-rapid} 5 5";
        };
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      settings = {
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
        }
        {
          block = "net";
          device = "enp14s0";
          format = " ^icon_net_wired $ip ";
          format_alt = " ^icon_net_wired $ipv6 ";
        }
        {
          block = "net";
          device = "wlp15s0";
          format = " ^icon_net_wireless $ip - $ssid ";
          format_alt = " ^icon_net_wireless $ipv6 ";
        }
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

  programs.fzf = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  # better cat
  programs.bat.enable = true;
  # better ls
  programs.lsd.enable = true;
  # better find
  programs.fd = {
    enable = true;
    ignores = [ ".git/" ];
  };
  # TUI file explorer
  programs.yazi.enable = true;

  home.shell.enableShellIntegration = true;
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "tim-oster";
    userEmail = "tim.oster99@gmail.com";
    extraConfig = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      commit.gpgsign = true;
      # 1password item: GitHub Workstation
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKq7+ma3TZvgZvpanpcJc16sU0entTACR6+F+bdFc+H";
    };

    delta = {
      enable = true;
      options.side-by-side = true;
    };
  };
  programs.lazygit.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };
}
