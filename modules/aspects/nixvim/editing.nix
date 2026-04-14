# Editing — treesitter, lz-n, auto-save, conform-nvim, mini.*, koda, render-markdown, fastaction, codediff
{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._.editing ];
  dots.nixvim._.editing.homeManager = { pkgs, lib, ... }: {
  programs.nixvim.plugins = {
    # Lazy loading
    lz-n.enable = true;

    # Treesitter
    treesitter = {
      enable = true;
      folding.enable = true;
      highlight.enable = true;
      indent.enable = true;
      nixvimInjections = true;
    };

    # Auto-save
    auto-save.enable = true;

    # Formatting
    conform-nvim = {
      enable = true;
      lazyLoad.settings = { cmd = [ "ConformInfo" ]; event = [ "BufWritePre" ]; };
      luaConfig.pre = "local slow_format_filetypes = {}";
      settings = {
        default_format_opts.lsp_format = "fallback";
        format_on_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
            if slow_format_filetypes[vim.bo[bufnr].filetype] then return end
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match("/node_modules/") or bufname:match("/.direnv/") then return end
            local function on_format(err)
              if err and err:match("timeout$") then slow_format_filetypes[vim.bo[bufnr].filetype] = true end
            end
            return { timeout_ms = 200, lsp_fallback = true }, on_format
          end
        '';
        format_after_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
            if not slow_format_filetypes[vim.bo[bufnr].filetype] then return end
            return { lsp_fallback = true }
          end
        '';
        formatters_by_ft = {
          bash = [ "shellcheck" "shellharden" "shfmt" ];
          css = [ "stylelint" ];
          javascript = { __unkeyed-1 = "prettierd"; __unkeyed-2 = "biome"; timeout_ms = 2000; stop_after_first = true; };
          json = [ "biome-check" ];
          html = [ "prettierd" ];
          just = [ "just" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" "injected" ];
          python = [ "ruff_fix" "ruff_format" "ruff_organize_imports" ];
          sql = [ "sqlfluff" ];
          rust = [ "rustfmt" ];
          sh = [ "shellcheck" "shellharden" "shfmt" ];
          swift = [ "swift_format" ];
          typescript = { __unkeyed-1 = "prettierd"; __unkeyed-2 = "biome"; timeout_ms = 2000; stop_after_first = true; };
          xml = [ "xmlformat" "xmllint" ];
          yaml = [ "yamlfmt" ];
        };
        formatters = {
          biome = {
            command = pkgs.lib.getExe pkgs.biome;
            env.BIOME_CONFIG_PATH = pkgs.writeTextFile {
              name = "biome.json";
              text = pkgs.lib.generators.toJSON { } {
                "$schema" = "${pkgs.biome}/node_modules/@biomejs/biome/configuration_schema.json";
                formatter.useEditorconfig = true;
              };
            };
          };
          jq.command = pkgs.lib.getExe pkgs.jq;
          just.command = pkgs.lib.getExe pkgs.just;
          nixfmt.command = pkgs.lib.getExe pkgs.nixfmt;
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
          xmlformat.command = pkgs.lib.getExe pkgs.xmlformat;
          yamlfmt.command = pkgs.lib.getExe pkgs.yamlfmt;
          injected.ignore_errors = false;
        };
      };
    };

    # Mini modules
    mini-ai.enable = true;
    mini-extra.enable = true;
    mini-icons = { enable = true; mockDevIcons = true; };
    mini-statusline.enable = true;
    mini-surround.enable = true;
    mini = {
      enable = true;
      modules = {
        indentscope = { };
        snippets.snippets.__unkeyed-2.__raw = ''require("mini.snippets").gen_loader.from_lang()'';
      };
    };

    # Code actions
    fastaction = {
      enable = true;
      lazyLoad.settings.event = "LspAttach";
      settings.dismiss_keys = [ "j" "k" "<Esc>" "<C-c>" ];
    };

    # Render markdown (codecompanion, obsidian, opencode)
    render-markdown = {
      enable = true;
      lazyLoad.settings.ft = [ "codecompanion" "markdown" "opencode_output" ];
      settings = {
        completions.lsp.enabled = true;
        file_types = [ "codecompanion" "markdown" "opencode_output" ];
        render_modes = true;
      };
    };

    # Codediff
    codediff = {
      enable = true;
      settings.keymaps = {
        explorer = { select = "<CR>"; hover = "K"; refresh = "R"; };
        view = { next_hunk = "]c"; prev_hunk = "[c"; next_file = "]f"; prev_file = "[f"; };
      };
    };
  };

  # Snippets file
  programs.nixvim.extraFiles."snippets/nix.json".source = ./snippets/nix.json;

  # Codediff keymap
  programs.nixvim.keymaps = [
    { mode = [ "n" ]; key = "<leader>gd"; action = "<cmd>CodeDiff<cr>"; options.desc = "Open CodeDiff"; }
  ];

  # Lint
  programs.nixvim.plugins.lint = {
    enable = true;
    lazyLoad.settings.event = [ "BufReadPost" ];
    lintersByFt = {
      "yaml.ghaction" = [ "actionlint" "zizmor" "yamllint" ];
      "yaml.cloudformation" = [ "cfn_lint" "yamllint" ];
      dockerfile = [ "hadolint" ];
      yaml = [ "yamllint" ];
    };
    linters = {
      actionlint = {
        cmd = pkgs.lib.getExe pkgs.actionlint;
        args = [ "-format" "{{json .}}" "-stdin-filename" { __raw = "function() return vim.api.nvim_buf_get_name(0) end"; } "-" ];
      };
      cfn_lint.cmd = pkgs.lib.getExe pkgs.python3Packages.cfn-lint;
      hadolint.cmd = pkgs.lib.getExe pkgs.hadolint;
      yamllint.cmd = pkgs.lib.getExe pkgs.yamllint;
      zizmor.cmd = pkgs.lib.getExe pkgs.zizmor;
    };
    autoCmd = {
      event = [ "BufEnter" "BufWritePost" "InsertLeave" ];
      callback.__raw = ''
        function()
          local ok, lint = pcall(require, "lint")
          if not ok then return end
          local filetype = vim.bo.filetype
          if vim.bo.buftype ~= "" then return end
          local skip_filetypes = { "gitcommit", "gitrebase", "help", "qf" }
          if vim.tbl_contains(skip_filetypes, filetype) then return end
          if filetype == "yaml.ghaction" then
            local repo_root = vim.fs.root(0, ".git")
            if repo_root then lint.try_lint(nil, { cwd = repo_root }); return end
          end
          lint.try_lint()
        end
      '';
    };
  };

  programs.nixvim.filetype.pattern = {
    ".*/%.github/workflows/.*%.ya?ml" = "yaml.ghaction";
    ".*cloudformation.*%.ya?ml" = "yaml.cloudformation";
    ".*%-stack%.ya?ml" = "yaml.cloudformation";
    ".*template%.ya?ml" = "yaml.cloudformation";
  };

  # Koda
  programs.nixvim.extraPlugins = [ pkgs.local.koda-nvim ];
  programs.nixvim.extraConfigLua = ''require("koda").setup({ auto = false, cache = true, })'';
  };
}
