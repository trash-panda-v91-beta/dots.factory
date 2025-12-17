{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.opencode.lsp";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode.settings.lsp = {
      nixd = {
        command = [ (pkgs.lib.getExe pkgs.nixd) ];
        extensions = [ ".nix" ];
        initialization = {
          formatting = {
            command = [ (pkgs.lib.getExe pkgs.nixfmt) ];
          };
        };
      };

      basedpyright = {
        command = [ (pkgs.lib.getExe pkgs.basedpyright) ];
        extensions = [
          ".py"
          ".pyi"
        ];
      };

      ruff = {
        command = [
          (pkgs.lib.getExe pkgs.ruff)
          "server"
        ];
        extensions = [
          ".py"
          ".pyi"
        ];
      };

      typescript = {
        command = [
          (pkgs.lib.getExe pkgs.typescript-language-server)
          "--stdio"
        ];
        extensions = [
          ".ts"
          ".tsx"
          ".js"
          ".jsx"
          ".mjs"
          ".cjs"
          ".mts"
          ".cts"
        ];
      };

      gopls = {
        command = [ (pkgs.lib.getExe pkgs.gopls) ];
        extensions = [
          ".go"
          ".mod"
          ".sum"
        ];
      };

      rust-analyzer = {
        command = [ (pkgs.lib.getExe pkgs.rust-analyzer) ];
        extensions = [ ".rs" ];
      };

      yamlls = {
        command = [
          (pkgs.lib.getExe pkgs.yaml-language-server)
          "--stdio"
        ];
        extensions = [
          ".yaml"
          ".yml"
        ];
      };

      jsonls = {
        command = [
          (pkgs.lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server")
          "--stdio"
        ];
        extensions = [
          ".json"
          ".jsonc"
        ];
      };

      just-lsp = {
        command = [ (pkgs.lib.getExe pkgs.just-lsp) ];
        extensions = [
          ".just"
          "Justfile"
          ".justfile"
        ];
      };

      tombi = {
        command = [
          (pkgs.lib.getExe pkgs.tombi)
          "lsp"
        ];
        extensions = [ ".toml" ];
      };

      rumdl = {
        command = [ (pkgs.lib.getExe pkgs.rumdl) ];
        extensions = [
          ".md"
          ".markdown"
        ];
      };
    };
  };
}
