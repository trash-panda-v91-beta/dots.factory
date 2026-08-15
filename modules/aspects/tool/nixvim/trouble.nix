{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.trouble ];
  dots.tool._.nixvim._.trouble.homeManager = { ... }: {
    programs.nixvim = {
      plugins.trouble = {
        enable = true;
        lazyLoad.settings.cmd = [ "Trouble" ];
        settings = {
          auto_close = true;
          focus = true;
          modes = {
            lsp_references = {
              params = {
                include_declaration = false;
              };
            };
          };
        };
      };

      keymaps = [
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Trouble)"; }
        { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Buffer Diagnostics (Trouble)"; }
        { mode = "n"; key = "<leader>xs"; action = "<cmd>Trouble symbols toggle<cr>"; options.desc = "Symbols (Trouble)"; }
        { mode = "n"; key = "<leader>xr"; action = "<cmd>Trouble lsp_references toggle<cr>"; options.desc = "LSP References (Trouble)"; }
        { mode = "n"; key = "<leader>xd"; action = "<cmd>Trouble lsp_definitions toggle<cr>"; options.desc = "LSP Definitions (Trouble)"; }
        { mode = "n"; key = "<leader>xl"; action = "<cmd>Trouble loclist toggle<cr>"; options.desc = "Location List (Trouble)"; }
        { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble qflist toggle<cr>"; options.desc = "Quickfix List (Trouble)"; }
      ];
    };
  };
}
