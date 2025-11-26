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

      bashls = {
        command = [
          (pkgs.lib.getExe pkgs.bash-language-server)
          "start"
        ];
        extensions = [
          ".sh"
          ".bash"
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

      taplo = {
        command = [
          (pkgs.lib.getExe pkgs.taplo)
          "lsp"
          "stdio"
        ];
        extensions = [ ".toml" ];
      };
    };
  };
}
