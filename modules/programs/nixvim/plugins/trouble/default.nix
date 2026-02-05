{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.trouble";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.trouble = {
      enable = true;
      lazyLoad.settings.cmd = [
        "Trouble"
      ];
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

    # Snacks picker integration: send results to Trouble with <c-x>
    plugins.snacks.settings.picker = {
      actions.trouble_open.__raw = ''
        function(picker)
          picker:close()
          local sel = picker:selected({ fallback = true })
          local items = {}
          for _, item in ipairs(sel) do
            local text = item.text or item.file or ""
            table.insert(items, {
              filename = item.file,
              lnum = item.pos and item.pos[1] or 1,
              col = item.pos and item.pos[2] or 0,
              text = text,
            })
          end
          if #items > 0 then
            vim.fn.setqflist(items, "r")
            require("trouble").open({ mode = "qflist" })
          end
        end
      '';
      win.input.keys."<c-x>" = {
        __unkeyed-1 = "trouble_open";
        mode = [
          "n"
          "i"
        ];
      };
    };

    keymaps = [
      {
        mode = [ "n" ];
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options = {
          desc = "Diagnostics (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options = {
          desc = "Buffer Diagnostics (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xs";
        action = "<cmd>Trouble symbols toggle<cr>";
        options = {
          desc = "Symbols (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xr";
        action = "<cmd>Trouble lsp_references toggle<cr>";
        options = {
          desc = "LSP References (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xd";
        action = "<cmd>Trouble lsp_definitions toggle<cr>";
        options = {
          desc = "LSP Definitions (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xl";
        action = "<cmd>Trouble loclist toggle<cr>";
        options = {
          desc = "Location List (Trouble)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>xq";
        action = "<cmd>Trouble qflist toggle<cr>";
        options = {
          desc = "Quickfix List (Trouble)";
        };
      }
    ];
  };
}
