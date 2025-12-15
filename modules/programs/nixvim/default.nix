{
  delib,
  inputs,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim";

  options.programs.nixvim = with delib; {
    enable = boolOption host.codingFeatured;

    defaultEditor = boolOption true;
  };

  myconfig.always.args.shared.nixvimLib = inputs.nixvim.lib;
  home.always.imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        enable = true;
        inherit (cfg) defaultEditor;

        clipboard.register = "unnamedplus";

        diagnostic.settings = {
          float = {
            border = "rounded";
          };
          jump = {
            severity.__raw = "vim.diagnostic.severity.WARN";
          };
          severity_sort = true;
          signs = {
            text = {
              "__rawKey__vim.diagnostic.severity.ERROR" = "";
              "__rawKey__vim.diagnostic.severity.WARN" = "";
              "__rawKey__vim.diagnostic.severity.HINT" = "󰌵";
              "__rawKey__vim.diagnostic.severity.INFO" = "";
            };
            texthl = {
              "__rawKey__vim.diagnostic.severity.ERROR" = "DiagnosticError";
              "__rawKey__vim.diagnostic.severity.WARN" = "DiagnosticWarn";
              "__rawKey__vim.diagnostic.severity.HINT" = "DiagnosticHint";
              "__rawKey__vim.diagnostic.severity.INFO" = "DiagnosticInfo";
            };
          };
          virtual_lines = {
            current_line = true;
          };
          virtual_text = {
            severity.min = "warn";
            source = "if_many";
          };
          update_in_insert = false;
        };

        filetype = {
          extension = {
            ignore = "gitignore";
          };
          pattern = {
            "flake.lock" = "json";
          };
        };

        globals = {
          disable_diagnostics = false;
          disable_autoformat = false;

          mapleader = " ";
          maplocalleader = " ";

          loaded_ruby_provider = 0;
          loaded_perl_provider = 0;
          loaded_python_provider = 0;
        };

        luaLoader.enable = true;
        nixpkgs.config.allowUnfree = true;

        performance = {
          byteCompileLua = {
            enable = true;
            configs = true;
            luaLib = true;
            nvimRuntime = true;
            plugins = true;
          };
          combinePlugins = {
            standalonePlugins = with pkgs; [
              local.codecompanion-gitcommit-nvim
              vimPlugins.codecompanion-history-nvim
              vimPlugins.codecompanion-nvim
              vimPlugins.mini-nvim
              vimPlugins.nvim-treesitter
              vimPlugins.oil-nvim
            ];
          };
        };

        opts = {
          completeopt = "menu,menuone,noselect";
          conceallevel = 2;
          cursorline = true;
          cursorlineopt = "both";
          foldcolumn = "1";
          foldenable = true;
          foldlevel = 99;
          foldlevelstart = 99;
          list = true;
          listchars = "tab:» ,trail:·,nbsp:␣";
          matchtime = 1;
          number = true;
          relativenumber = true;
          scrolloff = 10;
          shiftwidth = 2;
          showmatch = true;
          showmode = false;
          sidescrolloff = 8;
          signcolumn = "yes";
          smartcase = true;
          softtabstop = 2;
          splitbelow = true;
          splitkeep = "screen";
          splitright = true;
          swapfile = false;
          synmaxcol = 240;
          tabstop = 2;
          termguicolors = true;
          textwidth = 0;
          timeoutlen = 300;
          undofile = true;
          updatetime = 200;
          winborder = "single";
          wrap = false;
        };

      };
    };
}
