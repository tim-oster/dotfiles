{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.helix;
in
{
  imports = [ ];

  options.custom.helix = {
    enable = lib.mkEnableOption "helix config";
    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = cfg.defaultEditor;
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
        language-server.vscode-json-language-server.command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";

        language = [
          {
            name = "nix";
            language-servers = [ "nil" ];
            auto-format = true;
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
  };
}
