{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.grug-far";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.grug-far = {
      enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>rr";
        action = "<cmd>GrugFar<CR>";
        options = {
          desc = "Search & Replace";
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>rw";
        action.__raw = ''
          function()
            local grug = require('grug-far')
            local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
            grug.open({
              prefills = {
                search = vim.fn.expand("<cword>"),
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              }
            })
          end
        '';
        options = {
          desc = "Replace word under cursor";
        };
      }
      {
        mode = "n";
        key = "<leader>rf";
        action.__raw = ''
          function()
            local grug = require('grug-far')
            grug.open({
              prefills = {
                paths = vim.fn.expand("%")
              }
            })
          end
        '';
        options = {
          desc = "Replace in current file";
        };
      }
      {
        mode = "v";
        key = "<leader>rs";
        action.__raw = ''
          function()
            local grug = require('grug-far')
            grug.with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
          end
        '';
        options = {
          desc = "Replace selection in file";
        };
      }
    ];
  };
}
