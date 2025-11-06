{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.devenv;
in
{
  imports = [ ];

  options.custom.devenv = {
    enable = lib.mkEnableOption "devenv config";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    programs.git.delta = {
      enable = true;
      options.side-by-side = true;
    };
    programs.git.extraConfig = {
      pull.rebase = true;
      rebase.autoStash = true;
    };

    programs.lazygit = {
      enable = true;
      settings = {
        git.autoFetch = false;
        git.overrideGpg = true;
      };
    };

    # aarch64-darwin is not supported directly
    services.podman.enable = !pkgs.stdenv.isDarwin;

    home.packages = lib.mkMerge [
      [
        pkgs.delve # go debugger
        pkgs.devenv
        pkgs.bruno
        pkgs.gemini-cli
        pkgs.claude-code
        pkgs.jetbrains.datagrip
      ]

      (lib.mkIf pkgs.stdenv.isLinux [
        (pkgs.writeShellScriptBin "ws-dev" ''
          ALLOWED_FOLDERS=("dev")
          DIR=''\$(fd --full-path $HOME --max-depth=1 --type directory ''\${ALLOWED_FOLDERS[@]} | rofi -dmenu -p "Select workspace: ")

          if [[ ''\$DIR -eq "" ]]; then
            exit
          fi

          i3-msg "append_layout ${./ws-dev.json}"

          google-chrome-stable &
          alacritty --working-directory "''\$HOME/''\$DIR" --command ''\$SHELL -c "direnv export \$SHELL | source && lazygit" &
          sleep 0.1
          alacritty --working-directory "''\$HOME/''\$DIR" --command ''\$SHELL -c "direnv export \$SHELL | source && hx" &
          sleep 0.1
          alacritty --working-directory "''\$HOME/''\$DIR" &
          sleep 0.1
          alacritty &
        '')

        (pkgs.writeShellScriptBin "ws-code" ''
          ALLOWED_FOLDERS=("dev")
          DIR=''\$(fd --full-path $HOME --max-depth=1 --type directory ''\${ALLOWED_FOLDERS[@]} | rofi -dmenu -p "Select workspace: ")

          if [[ ''\$DIR -eq "" ]]; then
            exit
          fi

          i3-msg "append_layout ${./ws-code.json}"

          google-chrome-stable &
          code -n "''\$HOME/''\$DIR" &
          alacritty &
        '')

        (pkgs.writeShellScriptBin "screenshot-area" ''
          ${lib.getExe pkgs.maim} -s | ${lib.getExe pkgs.xclip} -selection clipboard -target image/png
        '')
        (pkgs.writeShellScriptBin "screenshot-active-window" ''
          active_window=$(${lib.getExe pkgs.xdotool} getactivewindow)
          ${lib.getExe pkgs.maim} -i $active_window | ${lib.getExe pkgs.xclip} -selection clipboard -target image/png
        '')
      ])
    ];
  };
}
