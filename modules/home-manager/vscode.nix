{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.vscode;
in
{
  imports = [ ];

  options.custom.vscode = {
    enable = lib.mkEnableOption "vscode config";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = true;

        # extensions = [
        #   pkgs.vscode-extensions.rust-lang.rust-analyzer

        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "vscode-buf";
        #       publisher = "bufbuild";
        #       version = "0.7.0";
        #       hash = "sha256-B5/Gc+f3xaYpMTXFcQ9LJiAb9LBJX2aR+gh22up3Wi4=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "direnv";
        #       publisher = "mkhl";
        #       version = "0.17.0";
        #       hash = "sha256-9sFcfTMeLBGw2ET1snqQ6Uk//D/vcD9AVsZfnUNrWNg=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "flatbuffers";
        #       publisher = "gaborv";
        #       version = "0.1.0";
        #       hash = "sha256-3Wsm1iit5eC5njLFLbGhhAYNYpnAWJr74OlsRgQqCss=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "copilot";
        #       publisher = "github";
        #       version = "1.309.0";
        #       hash = "sha256-i1PcbbOBgULd+inwypezE/ZsePrJaqM2z6qrDcNBLVA=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "copilot-chat";
        #       publisher = "github";
        #       version = "0.26.7";
        #       hash = "sha256-aR6AGU/boDmYef0GWna5sUsyv9KYGCkugWpFIusDMNE=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "go";
        #       publisher = "golang";
        #       version = "0.46.1";
        #       hash = "sha256-R5SC6vMWT3alunlklJKcEKKJhNd6GI2MF9/QWwuNprs=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "vsliveshare";
        #       publisher = "ms-vsliveshare";
        #       version = "1.0.5948";
        #       hash = "sha256-KOu9zF5l6MTLU8z/l4xBwRl2X3uIE15YgHEZJrKSHGY=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "roo-cline";
        #       publisher = "rooveterinaryinc";
        #       version = "3.14.3";
        #       hash = "sha256-hYtjcxlHwtvESs08WdWuMGi10LIvdH5SEBeAI7ah8oc=";
        #     };
        #   })
        #   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "vim";
        #       publisher = "vscodevim";
        #       version = "1.29.0";
        #       hash = "sha256-J3V8SZJZ2LSL8QfdoOtHI1ZDmGDVerTRYP4NZU17SeQ=";
        #     };
        #   })
        # ];
        userSettings = {
          "update.showReleaseNotes" = false;

          "editor.formatOnSave" = true;

          "go.alternateTools" = {
            "go" = "${lib.getExe pkgs.go}";
            "gopls" = "${lib.getExe pkgs.gopls}";
            "dlv" = "${lib.getExe pkgs.delve}";
          };

          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
              };
            };
          };

          "extensions.experimental.affinity" = {
            "vscodevim.vim" = 1;
          };
          "vim.smartRelativeLine" = true;
          "vim.useSystemClipboard" = true;

          "roo-cline.allowedCommands" = [
            "npm test"
            "npm install"
            "tsc"
            "git log"
            "git diff"
            "git show"
            "buf generate"
            "sqlc generate"
          ];

          "git.enableSmartCommit" = true;
          "database-client.autoSync" = true;
          "workbench.tree.indent" = 16;
        };
      };
    };
  };
}
