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
      ignores = [
        ".git/"
        ".direnv/"
        ".devenv/"
        ".venv/"
        ".cache/"
        ".aider.*/*"
        "node_modules/"
      ];

      # default configs: https://github.com/helix-editor/helix/blob/master/languages.toml
      languages = {
        language-server = {
          nil.command = (lib.getExe pkgs.nil);
          gopls.command = (lib.getExe pkgs.gopls);
          golangci-lint-lsp = {
            command = (lib.getExe pkgs.golangci-lint-langserver);
            config.command = [
              (lib.getExe pkgs.golangci-lint)
              "run"
              "--output.json.path=stdout"
              "--show-stats=false"
              "--issues-exit-code=1"
            ];
          };
          vscode-css-language-server.command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
          vscode-html-language-server.command = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
          vscode-json-language-server.command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
          typescript-language-server.command = (lib.getExe pkgs.typescript-language-server);
          yaml-language-server.command = (lib.getExe pkgs.yaml-language-server);
          buf.command = (lib.getExe pkgs.buf);
        };

        language = [
          {
            name = "nix";
            language-servers = [ "nil" ];
            auto-format = true;
            formatter = {
              command = (lib.getExe pkgs.nixfmt-rfc-style);
            };
          }
          {
            name = "yaml";
            language-servers = [ "yaml-language-server" ];
            auto-format = true;
            formatter = {
              command = (lib.getExe pkgs.yamlfmt);
              args = [ "-" ];
            };
          }
          {
            name = "html";
            auto-format = false;
            formatter = {
              command = (lib.getExe pkgs.nodePackages.prettier);
              args = [
                "--parser"
                "html"
              ];
            };
          }
          {
            name = "json";
            auto-format = false;
            formatter = {
              command = (lib.getExe pkgs.nodePackages.prettier);
              args = [
                "--parser"
                "json"
              ];
            };
          }
          {
            name = "css";
            auto-format = true;
            formatter = {
              command = (lib.getExe pkgs.nodePackages.prettier);
              args = [
                "--parser"
                "css"
              ];
            };
          }
          {
            name = "javascript";
            auto-format = true;
            formatter = {
              command = (lib.getExe pkgs.nodePackages.prettier);
              args = [
                "--parser"
                "typescript"
              ];
            };
          }
          {
            name = "typescript";
            auto-format = true;
            formatter = {
              command = (lib.getExe pkgs.nodePackages.prettier);
              args = [
                "--parser"
                "typescript"
              ];
            };
          }
          {
            name = "protobuf";
            auto-format = true;
            language-servers = [ "buf" ];
          }
        ];
      };
      settings = {
        editor = {
          line-number = "relative";
          cursorline = true;
          rulers = [ 120 ];
          insert-final-newline = true;

          cursor-shape.insert = "bar";

          completion-timeout = 50;

          file-picker = {
            hidden = false;
            parents = false;
            ignore = false;
            git-ignore = false;
            git-global = false;
            git-exclude = false;
          };

          indent-guides = {
            render = true;
            skip-levels = 1;
          };

          lsp.display-messages = true;

          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";
        };

        keys = {
          normal = {
            "A-w" = "move_next_sub_word_start";
            "A-b" = "move_prev_sub_word_start";
            "A-e" = "move_next_sub_word_end";
          };
          select = {
            "A-w" = "move_next_sub_word_start";
            "A-b" = "move_prev_sub_word_start";
            "A-e" = "move_next_sub_word_end";
          };
          insert = {
            "A-left" = [
              "move_prev_word_start"
              "collapse_selection"
            ];
            "A-right" = [
              "move_next_word_end"
              "move_char_right"
              "collapse_selection"
            ];
            "A-i" = "normal_mode";
          };
        };
      };
    };
  };
}
