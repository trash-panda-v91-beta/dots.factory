{ dots, ... }:
{
  dots.tool._.ai.includes = [ dots.tool._.ai._."ai-pi-prompt" ];
  dots.tool._.ai._."ai-pi-prompt".homeManager = { ... }: {
    programs.nixvim = {
      extraConfigLua = ''
        local function pi_send(msg)
          local sock = "/tmp/pi-nvim-latest.sock"
          if not vim.uv.fs_stat(sock) then
            vim.notify("pi not running", vim.log.levels.WARN)
            return
          end
          local client = vim.uv.new_pipe(false)
          client:connect(sock, function(err)
            if err then
              vim.schedule(function()
                vim.notify("pi: " .. err, vim.log.levels.ERROR)
              end)
              return
            end
            client:write(vim.json.encode({ type = "prompt", message = msg }) .. "\n")
            client:close()
          end)
        end

        local function pi_prompt(prefix)
          vim.ui.input({ prompt = "pi: " }, function(input)
            if input and input ~= "" then
              pi_send((prefix or "") .. input)
            end
          end)
        end

        vim.keymap.set("n", "<leader>p", function()
          local file = vim.fn.expand("%:.")
          if file == "" then
            vim.notify("no file", vim.log.levels.WARN)
            return
          end
          pi_prompt(string.format("@%s\n\n", file))
        end, { desc = "Ask pi about current file" })
        vim.keymap.set("v", "<leader>p", function()
          local s = vim.fn.getpos("'<")
          local e = vim.fn.getpos("'>")
          -- getregion needs to run before we drop back to normal mode
          vim.cmd("normal! \27")
          local lines = vim.fn.getregion(s, e, { type = "v" })
          local ft = vim.bo.filetype == "markdown" and "md" or vim.bo.filetype
          local ctx = string.format(
            "@%s:%d-%d\n```%s\n%s\n```\n\n",
            vim.fn.expand("%:."), s[2], e[2], ft, table.concat(lines, "\n")
          )
          pi_prompt(ctx)
        end, { desc = "Ask pi about selection" })
      '';

      plugins.which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>p";
          group = "Pi";
          icon = "🥧";
          mode = [ "n" "v" ];
        }
      ];
    };
  };
}
