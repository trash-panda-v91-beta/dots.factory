{
  delib,
  pkgs,
  self,
  ...
}:
delib.module {
  name = "programs.nixvim.lsp";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.lsp = {
    inlayHints.enable = true;
    servers = {
      "*" = {
        config = {
          capabilities = {
            textDocument = {
              semanticTokens = {
                multilineTokenSupport = true;
              };
            };
          };
          root_markers = [
            ".git"
          ];
        };
      };
      basedpyright = {
        enable = true;
        config = {
          disableOrganizeImports = true;
        };
      };
      bashls.enable = true;
      biome.enable = true;
      dockerls.enable = true;
      eslint.enable = true;
      fish_lsp.enable = true;
      gopls.enable = true;
      harper_ls = {
        enable = true;
        config.settings = {
          "harper-ls" = {
            linters = {
              boring_words = true;
              linking_verbs = true;
              sentence_capitalization = false;
            };
            codeActions = {
              forceStable = true;
            };
          };
        };
      };
      html.enable = true;
      jsonls.enable = true;
      kulala_ls.enable = true;
      lua_ls = {
        enable = true;
        config = {
          format = {
            enable = false;
          };
          telemetry = {
            enable = false;
          };
        };
      };
      nixd = {
        enable = true;
        config =
          let
            wrapper = builtins.toFile "expr.nix" ''
              import ${./_nixd-expr} {
                self = ${builtins.toJSON self};
                system = ${builtins.toJSON pkgs.stdenv.hostPlatform.system};
              }
            '';
            withFlakes = expr: "with import ${wrapper}; " + expr;
          in
          {
            nixpkgs.expr = withFlakes ''
              import (if local ? lib.version then local else local.inputs.nixpkgs or global.inputs.nixpkgs) { }
            '';
            options = rec {
              flake-parts.expr = withFlakes "local.debug.options or global.debug.options";
              nixos.expr = withFlakes "global.nixosConfigurations.desktop.options";
              home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions [ ]";
              nixvim.expr = withFlakes "global.nixvimConfigurations.\${system}.default.options";
            };
          };
      };
      nushell.enable = true;
      ruff.enable = true;
      sqls.enable = true;
      statix.enable = true;
      stylelint_lsp.enable = true;
      tailwindcss.enable = true;
      taplo.enable = true;
      ts_ls.enable = true;
      yamlls = {
        enable = true;
        config = {
          settings = {
            redhat = {
              telemetry = {
                enabled = false;
              };
            };
          };
          settings.yaml = {
            customTags = [
              "!And scalar"
              "!And mapping"
              "!And sequence"
              "!If scalar"
              "!If mapping"
              "!If sequence"
              "!Not scalar"
              "!Not mapping"
              "!Not sequence"
              "!Equals scalar"
              "!Equals mapping"
              "!Equals sequence"
              "!Or scalar"
              "!Or mapping"
              "!Or sequence"
              "!FindInMap scalar"
              "!FindInMap mapping"
              "!FindInMap sequence"
              "!Base64 scalar"
              "!Base64 mapping"
              "!Base64 sequence"
              "!Cidr scalar"
              "!Cidr mapping"
              "!secret scalar"
              "!include_dir_named scalar"
              "!Cidr sequence"
              "!Ref scalar"
              "!Ref mapping"
              "!Ref sequence"
              "!Sub scalar"
              "!Sub mapping"
              "!Sub sequence"
              "!GetAtt scalar"
              "!GetAtt mapping"
              "!GetAtt sequence"
              "!GetAZs scalar"
              "!GetAZs mapping"
              "!GetAZs sequence"
              "!ImportValue scalar"
              "!ImportValue mapping"
              "!ImportValue sequence"
              "!Select scalar"
              "!Select mapping"
              "!Select sequence"
              "!Split scalar"
              "!Split mapping"
              "!Split sequence"
              "!Join scalar"
              "!Join mapping"
              "!Join sequence"
            ];
          };
        };
      };
    };
  };
}
