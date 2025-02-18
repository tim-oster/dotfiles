{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.wifimenu;
in
{
  imports = [ ];

  options.programs.wifimenu = {
    enable = lib.mkEnableOption "wifimenu rofi script";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkMerge [
      [
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
      ]
    ];
  };
}
