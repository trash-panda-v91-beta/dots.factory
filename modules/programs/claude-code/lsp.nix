{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.claude-code.lsp";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.claude-code.lspServers = {
      nixd = {
        command = (pkgs.lib.getExe pkgs.nixd);
        args = [ ];
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };

      ty = {
        command = (pkgs.lib.getExe pkgs.ty);
        args = [ "server" ];
        extensionToLanguage = {
          ".py" = "python";
          ".pyi" = "python";
        };
      };

      ruff = {
        command = (pkgs.lib.getExe pkgs.ruff);
        args = [ "server" ];
        extensionToLanguage = {
          ".py" = "python";
          ".pyi" = "python";
        };
      };

      typescript = {
        command = (pkgs.lib.getExe pkgs.typescript-language-server);
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
          ".mts" = "typescript";
          ".cts" = "typescript";
        };
      };

      gopls = {
        command = (pkgs.lib.getExe pkgs.gopls);
        args = [ ];
        extensionToLanguage = {
          ".go" = "go";
          ".mod" = "gomod";
          ".sum" = "gosum";
        };
      };

      rust-analyzer = {
        command = (pkgs.lib.getExe pkgs.rust-analyzer);
        args = [ ];
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };

      yaml-language-server = {
        command = (pkgs.lib.getExe pkgs.yaml-language-server);
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".yaml" = "yaml";
          ".yml" = "yaml";
        };
      };

      json-language-server = {
        command = (pkgs.lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server");
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".json" = "json";
          ".jsonc" = "jsonc";
        };
      };
    };
  };
}
