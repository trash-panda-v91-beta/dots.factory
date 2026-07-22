{ dots, ... }:
{
  dots.tool._.ai.includes = [ dots.tool._.ai._."ai-pi-prompt" ];
  dots.tool._.ai._."ai-pi-prompt".homeManager = { ... }: {
    programs.nixvim = {
      extraConfigLua = ''
        local function pi_list_socks()
          local out = {}
          for _, path in ipairs(vim.fn.glob("/tmp/pi-nvim-sockets/*.info", false, true)) do
            local fd = io.open(path, "r")
            if fd then
              local ok, info = pcall(vim.json.decode, fd:read("*a"))
              fd:close()
              if ok and info.cwd then
                local sock = (path:gsub("%.info$", ""))
                if vim.uv.fs_stat(sock) then
                  table.insert(out, { sock = sock, cwd = info.cwd, startedAt = info.startedAt or "" })
                end
              end
            end
          end
          table.sort(out, function(a, b) return a.cwd < b.cwd end)
          return out
        end

        local function pi_find_sock()
          local cwd = vim.fn.getcwd()
          local best, best_len, best_time = nil, -1, ""
          for _, s in ipairs(pi_list_socks()) do
            if cwd == s.cwd or vim.startswith(cwd, s.cwd .. "/") then
              local len = #s.cwd
              if len > best_len or (len == best_len and s.startedAt > best_time) then
                best, best_len, best_time = s, len, s.startedAt
              end
            end
          end
          if best then return best.sock, best.cwd end
          return "/tmp/pi-nvim-latest.sock", "latest (fallback)"
        end

        local function pi_send(msg, sock)
          sock = sock or pi_find_sock()
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
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].filetype = "markdown"
          if prefix and prefix ~= "" then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(prefix, "\n", { plain = true }))
          end
          local target_sock, target_cwd = pi_find_sock()
          local width = math.min(100, math.floor(vim.o.columns * 0.7))
          local height = math.min(20, math.floor(vim.o.lines * 0.4))
          local function title_for(cwd)
            return " pi -> " .. vim.fn.fnamemodify(cwd, ":t") .. " "
          end
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            style = "minimal",
            border = "rounded",
            title = title_for(target_cwd),
            title_pos = "center",
            footer = " <C-s> send  <C-t> target  <Esc>/q cancel ",
            footer_pos = "center",
          })
          vim.api.nvim_buf_set_name(buf, "pi://prompt")
          vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          vim.cmd("startinsert!")

          local function submit()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local msg = table.concat(lines, "\n")
            if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
            if msg:gsub("%s", "") ~= "" then pi_send(msg, target_sock) end
          end
          local function cancel()
            if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
          end
          local function pick_target()
            local socks = pi_list_socks()
            if #socks == 0 then
              vim.notify("no pi sessions running", vim.log.levels.WARN)
              return
            end
            vim.ui.select(socks, {
              prompt = "pi target:",
              format_item = function(s) return s.cwd end,
            }, function(choice)
              if not choice then return end
              target_sock, target_cwd = choice.sock, choice.cwd
              if vim.api.nvim_win_is_valid(win) then
                pcall(vim.api.nvim_win_set_config, win, { title = title_for(target_cwd), title_pos = "center" })
              end
            end)
          end

          local opts = { buffer = buf, nowait = true, silent = true }
          vim.keymap.set({ "n", "i" }, "<C-s>", submit, opts)
          vim.keymap.set({ "n", "i" }, "<C-t>", pick_target, opts)
          vim.keymap.set("n", "<CR>", submit, opts)
          vim.keymap.set("n", "q", cancel, opts)
          vim.keymap.set("n", "<Esc>", cancel, opts)
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
          -- exit visual first so '< and '> are updated for this selection
          vim.cmd("normal! \27")
          local s = vim.fn.getpos("'<")
          local e = vim.fn.getpos("'>")
          local lines = vim.fn.getregion(s, e, { type = "v" })
          local ctx = string.format(
            "@%s:%d-%d\n```%s\n%s\n```\n\n",
            vim.fn.expand("%:."), s[2], e[2], vim.bo.filetype, table.concat(lines, "\n")
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
