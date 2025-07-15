{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.zed;
in
{
  imports = [ ];

  options.custom.zed = {
    enable = lib.mkEnableOption "zed config";
  };

  config = lib.mkIf cfg.enable {
    # stylix theme messes up some UI components in zed
    stylix.targets.zed.enable = false;

    programs.zed-editor = {
      enable = true;

      userSettings =
        let
          ruler_width = 120;
        in
        {
          autosave.after_delay.milliseconds = 500;
          restore_on_startup = "last_session";
          auto_update = false;
          base_keymap = "JetBrains";
          direnv = "shell_hook";
          hide_mouse = "never";

          minimap.show = "auto";

          tabs = {
            file_icons = true;
            git_status = true;
            show_diagnostics = "all";
          };

          ensure_final_newline_on_save = true;
          format_on_save = "on";

          diagnostics = {
            inline.enabled = true;
          };

          git = {
            inline_blame.enabled = false;
          };

          hard_tabs = true;
          hour_format = "hour24";

          preview_tabs.enabeld = false;

          preferred_line_length = ruler_width;
          remove_trailing_whitespace_on_save = true;
          wrap_guides = [ ruler_width ];
          tab_size = 4;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };

          vim_mode = true;
          relative_line_nubmers = true;
          vim = {
            toggle_relative_line_numbers = true;
          };

          buffer_font_family = config.stylix.fonts.monospace.name;
          buffer_font_size = config.stylix.fonts.sizes.terminal * 4.0 / 3.0;
          ui_font_family = config.stylix.fonts.sansSerif.name;
          ui_font_size = config.stylix.fonts.sizes.applications * 4.0 / 3.0;

          lsp = {
            protobuf-language-server = {
              binary = {
                path = "buf"; # prefer binary from direnv path instead of global version
                arguments = [
                  "beta"
                  "lsp"
                ];
              };
            };
          };
        };
    };
  };
}
