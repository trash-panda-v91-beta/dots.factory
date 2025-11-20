{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.words";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.snacks.settings.words = {
      enabled = true;

      # Debounce time in ms before highlighting
      debounce = 100;

      # Enable notifications when jumping between references
      notify_jump = false;
      notify_end = false;

      # Open folds when jumping to references
      foldopen = true;

      # Add jumps to the jumplist
      jumplist = true;

      # Filter function to control when highlighting is active
      filter.__raw = ''
        function(buf)
          -- Check global and buffer-local disable flags
          if vim.g.snacks_words == false or vim.b[buf].snacks_words == false then
            return false
          end

          -- Exclude certain filetypes
          local ft = vim.bo[buf].filetype
          local deny_filetypes = {
            "dirvish",
            "fugitive",
            "neo-tree",
            "nvim-tree",
            "oil",
            "TelescopePrompt",
            "noice",
          }
          for _, denied_ft in ipairs(deny_filetypes) do
            if ft == denied_ft then
              return false
            end
          end

          -- Disable for large files (over 3000 lines)
          local line_count = vim.api.nvim_buf_line_count(buf)
          if line_count > 3000 then
            return false
          end

          return true
        end
      '';
    };

    keymaps = [
      {
        mode = "n";
        key = "]]";
        action = "<cmd>lua Snacks.words.jump(vim.v.count1)<CR>";
        options = {
          desc = "Next Reference";
        };
      }
      {
        mode = "n";
        key = "[[";
        action = "<cmd>lua Snacks.words.jump(-vim.v.count1)<CR>";
        options = {
          desc = "Previous Reference";
        };
      }
    ];
  };
}
