{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.conform-nvim";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
  plugins.conform-nvim = {
    enable = true;
    lazyLoad.settings = {
      cmd = [
        "ConformInfo"
      ];
      event = [ "BufWritePre" ];
    };
    luaConfig.pre = ''
      local slow_format_filetypes = {}
    '';
    settings = {
      default_format_opts = {
        lsp_format = "fallback";
      };
      format_on_save = # Lua
        ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

             -- Disable autoformat for slow filetypes
            if slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

             -- Disable autoformat for files in a certain path
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match("/node_modules/") or bufname:match("/.direnv/") then
              return
            end

            local function on_format(err)
              if err and err:match("timeout$") then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
              end
            end

            return { timeout_ms = 200, lsp_fallback = true }, on_format
           end
        '';
      format_after_save = # Lua
        ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if not slow_format_filetypes[vim.bo[bufnr].filetype] then
              return 
            end 
            return { lsp_fallback = true }
          end
        '';
      formatters_by_ft = {
        bash = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        css = [ "stylelint" ];
        fish = [ "fish_indent" ];
        javascript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "biome";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        json = [ "jq" ];
        html = [ "prettierd" ];
        lua = [ "stylua" ];
        nix = [
          "nixfmt"
          "injected"
        ];
        python = [
          "ruff_fix"
          "ruff_format"
          "ruff_organize_imports"
        ];
        sql = [ "sqlfluff" ];
        rust = [ "rustfmt" ];
        sh = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        swift = [ "swift_format" ];
        toml = [ "taplo" ];
        typescript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "biome";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        xml = [
          "xmlformat"
          "xmllint"
        ];
        yaml = [ "yamlfmt" ];
      };
      formatters = {
        biome = {
          command = pkgs.lib.getExe pkgs.biome;
          env = {
            BIOME_CONFIG_PATH = pkgs.writeTextFile {
              name = "biome.json";
              text = pkgs.lib.generators.toJSON { } {
                "$schema" = "${pkgs.biome}/node_modules/@biomejs/biome/configuration_schema.json";
                formatter.useEditorconfig = true;
              };
            };
          };
        };
        jq.command = pkgs.lib.getExe pkgs.jq;
        nixfmt.command = pkgs.lib.getExe pkgs.nixfmt-rfc-style;
        prettierd.command = pkgs.lib.getExe pkgs.prettierd;
        ruff.command = pkgs.lib.getExe pkgs.ruff;
        rustfmt.command = pkgs.lib.getExe pkgs.rustfmt;
        shellcheck.command = pkgs.lib.getExe pkgs.shellcheck;
        shellharden.command = pkgs.lib.getExe pkgs.shellharden;
        shfmt.command = pkgs.lib.getExe pkgs.shfmt;
        sqlfluff.command = pkgs.lib.getExe pkgs.sqlfluff;
        stylelint.command = pkgs.lib.getExe pkgs.stylelint;
        stylua.command = pkgs.lib.getExe pkgs.stylua;
        swift_format.command = pkgs.lib.getExe pkgs.swift-format;
        taplo.command = pkgs.lib.getExe pkgs.taplo;
        xmlformat.command = pkgs.lib.getExe pkgs.xmlformat;
        yamlfmt.command = pkgs.lib.getExe pkgs.yamlfmt;
        injected = {
          ignore_errors = false;
        };
      };
    };

  };
  };
}
