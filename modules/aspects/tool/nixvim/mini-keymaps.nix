{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._."mini-keymaps" ];
  dots.tool._.nixvim._."mini-keymaps".homeManager = { ... }: {
    programs.nixvim.keymaps = [
      # Buffer management (mini.bufremove)
      { mode = "n"; key = "<C-w>"; action = "<cmd>lua MiniBufremove.delete()<cr>"; options.desc = "Close buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>lua MiniBufremove.delete()<cr>"; options.desc = "Delete buffer"; }
      { mode = "n"; key = "<leader>bb"; action = "<cmd>e #<cr>"; options.desc = "Switch to last buffer"; }
      { mode = "n"; key = "<leader>bc"; action.__raw = ''
        function()
          local cur = vim.api.nvim_get_current_buf()
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if b ~= cur and vim.bo[b].buflisted then
              pcall(function() MiniBufremove.delete(b) end)
            end
          end
        end
      ''; options.desc = "Close all buffers but current"; }
      { mode = "n"; key = "<leader>bC"; action.__raw = ''
        function()
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[b].buflisted then pcall(function() MiniBufremove.delete(b) end) end
          end
        end
      ''; options.desc = "Close all buffers"; }

      # Notifications (mini.notify)
      { mode = "n"; key = "<leader>un"; action = "<cmd>lua MiniNotify.clear()<cr>"; options.desc = "Dismiss all notifications"; }
      { mode = "n"; key = "<leader>uN"; action = "<cmd>lua MiniNotify.show_history()<cr>"; options.desc = "Show notification history"; }
    ];
  };
}
