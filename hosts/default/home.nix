{ config, pkgs, lib, ... }:

{
  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    google-chrome
    obsidian
    i3lock-fancy-rapid
    pavucontrol
    neofetch

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

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # envvars available in home manager managed shells
  home.sessionVariables = {
  };

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
  stylix.fonts.sizes = let size = 10; in {
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
  programs.helix.enable = true;
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
        (config.lib.stylix.i3.bar // {
          position = "bottom";
          statusCommand = "${lib.getExe pkgs.i3status-rust} config-default.toml";
        })
      ];

      startup = [
        { command = "i3-msg workspace 1"; always = false; notification = false; }
        { command = "${lib.getExe pkgs._1password-gui} --silent"; always = false; notification = true; }
      ];
       
      keybindings = let modifier = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
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
            { button = "left"; cmd = "pavucontrol"; }
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

  programs.bat.enable = true;

  home.shell.enableShellIntegration = true;
  programs.direnv.enable = true;

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
