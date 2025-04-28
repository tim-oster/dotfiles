{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.cursor;
in
{
  imports = [ ];

  options.custom.cursor = {
    enable = lib.mkEnableOption "cursor config";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = [
          pkgs.vscode-extensions.rust-lang.rust-analyzer

          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "vscode-buf";
              publisher = "bufbuild";
              version = "0.7.0";
              hash = "sha256-B5/Gc+f3xaYpMTXFcQ9LJiAb9LBJX2aR+gh22up3Wi4=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "direnv";
              publisher = "mkhl";
              version = "0.17.0";
              hash = "sha256-9sFcfTMeLBGw2ET1snqQ6Uk//D/vcD9AVsZfnUNrWNg=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "flatbuffers";
              publisher = "gaborv";
              version = "0.1.0";
              hash = "sha256-3Wsm1iit5eC5njLFLbGhhAYNYpnAWJr74OlsRgQqCss=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "copilot";
              publisher = "github";
              version = "1.309.0";
              hash = "sha256-i1PcbbOBgULd+inwypezE/ZsePrJaqM2z6qrDcNBLVA=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "copilot-chat";
              publisher = "github";
              version = "0.26.7";
              hash = "sha256-aR6AGU/boDmYef0GWna5sUsyv9KYGCkugWpFIusDMNE=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "go";
              publisher = "golang";
              version = "0.46.1";
              hash = "sha256-R5SC6vMWT3alunlklJKcEKKJhNd6GI2MF9/QWwuNprs=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "vsliveshare";
              publisher = "ms-vsliveshare";
              version = "1.0.5948";
              hash = "sha256-KOu9zF5l6MTLU8z/l4xBwRl2X3uIE15YgHEZJrKSHGY=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "roo-cline";
              publisher = "rooveterinaryinc";
              version = "3.14.3";
              hash = "sha256-hYtjcxlHwtvESs08WdWuMGi10LIvdH5SEBeAI7ah8oc=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "vim";
              publisher = "vscodevim";
              version = "1.29.0";
              hash = "sha256-J3V8SZJZ2LSL8QfdoOtHI1ZDmGDVerTRYP4NZU17SeQ=";
            };
          })
        ];
        userSettings = {
          "update.showReleaseNotes" = false;

          "editor.formatOnSave" = true;

          "go.alternateTools" = {
            "go" = "${lib.getExe pkgs.go}";
            "gopls" = "${lib.getExe pkgs.gopls}";
            "dlv" = "${lib.getExe pkgs.delve}";
          };

          "extensions.experimental.affinity" = {
            "vscodevim.vim" = 1;
          };

          "vim.smartRelativeLine" = true;
          "vim.useSystemClipboard" = true;
        };
      };
    };

    home.packages = lib.mkMerge [
      [
        pkgs.code-cursor
      ]
    ];

    home.file.".config/Cursor/User/settings.json" = {
      text = ''
        {
            "window.commandCenter": 1,
            "editor.fontSize": 12,
            "update.mode": "none",
            "update.showReleaseNotes": false,
            "extensions.autoUpdate": false,
            "go.alternateTools": {
                "go": "${lib.getExe pkgs.go}",
                "gopls": "${lib.getExe pkgs.gopls}",
                "dlv": "${lib.getExe pkgs.delve}",
            },
        }
      '';
    };
  };
}
