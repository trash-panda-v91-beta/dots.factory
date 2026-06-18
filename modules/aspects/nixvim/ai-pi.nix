{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."ai-pi" ];
  dots.nixvim._."ai-pi".homeManager =
    { pkgs, ... }:
    {
      programs.nixvim = {
        extraPackages = [ pkgs.pi-coding-agent ];
        extraPlugins = [ pkgs.local.pi-nvim ];

        keymaps = [
          { mode = [ "n" "v" ]; key = "<leader>pp"; action = "<Cmd>Pi layout=float<CR>";    options.desc = "Pi"; }
          { mode = [ "n" "v" ]; key = "<leader>pl"; action = "<Cmd>PiToggleLayout<CR>";     options.desc = "Pi toggle layout"; }
          { mode = [ "n" "v" ]; key = "<leader>pc"; action = "<Cmd>PiContinue<CR>";         options.desc = "Pi continue last session"; }
          { mode = [ "n" "v" ]; key = "<leader>pr"; action = "<Cmd>PiResume<CR>";           options.desc = "Pi resume past session"; }
          { mode = [ "n" "v" ]; key = "<leader>pm"; action = "<Cmd>PiSendMention<CR>";      options.desc = "Pi mention file/selection"; }
          { mode = [ "n" "v" ]; key = "<leader>pa"; action = "<Cmd>PiAttention<CR>";        options.desc = "Pi open next attention request"; }
        ];

        extraConfigLua = ''
          require("pi").setup({
            spinner = "robot",
            show_thinking = false,
            layout = { default = "float" },
            debug = true,
          })

          local pi = require("pi")
          local group = vim.api.nvim_create_augroup("pi-keymaps", { clear = true })

          local function map(buf, key, action, modes)
            vim.keymap.set(modes or { "n", "i", "v" }, key, action, { buffer = buf })
          end

          vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = { "pi-chat-history", "pi-chat-prompt", "pi-chat-attachments" },
            callback = function(event)
              map(event.buf, "<C-q>", "<Cmd>PiToggleChat<CR>")
              map(event.buf, "<M-c>", "<Cmd>PiAbort<CR>")
              map(event.buf, "<C-o>", pi.toggle_history_blocks)
            end,
          })

          vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "pi-chat-history",
            callback = function(event)
              map(event.buf, "<S-Down>", pi.focus_chat_prompt)
            end,
          })

          vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "pi-chat-prompt",
            callback = function(event)
              -- Override pi.nvim's synchronous completefunc to prevent freeze on @;
              -- blink.cmp handles completion via pi.completion.blink instead.
              vim.bo[event.buf].completefunc = ""
              map(event.buf, "<S-Up>",   pi.focus_chat_history)
              map(event.buf, "<S-Down>", pi.focus_chat_attachments)
              map(event.buf, "<C-Up>",   function() pi.scroll_chat_history("up", 2) end)
              map(event.buf, "<C-Down>", function() pi.scroll_chat_history("down", 2) end)
              map(event.buf, "<M-m>", pi.cycle_model)
              map(event.buf, "<M-M>", pi.select_model)
              map(event.buf, "<M-t>", pi.cycle_thinking_level)
              map(event.buf, "<M-T>", pi.select_thinking_level)
              map(event.buf, "<M-n>", pi.new_session)
              map(event.buf, "<M-x>", pi.compact)
              map(event.buf, "<C-v>", pi.paste_image)
            end,
          })

          vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "pi-chat-attachments",
            callback = function(event)
              map(event.buf, "<S-Up>", pi.focus_chat_prompt)
              map(event.buf, "<C-v>",  pi.paste_image)
            end,
          })
        '';
      };
    };
}
