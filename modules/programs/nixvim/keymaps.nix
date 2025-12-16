{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.keymaps";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    # Yank utilities for copying file paths with code
    extraConfigLua = ''
      local yank = {}

      yank.get_buffer_absolute = function()
        return vim.fn.expand '%:p'
      end

      yank.get_buffer_cwd_relative = function()
        return vim.fn.expand '%:.'
      end

      yank.get_visual_bounds = function()
        local mode = vim.fn.mode()
        if mode ~= 'v' and mode ~= 'V' then
          error('get_visual_bounds must be called in visual or visual-line mode (current mode: ' .. vim.inspect(mode) .. ')')
        end
        local is_visual_line_mode = mode == 'V'
        local start_pos = vim.fn.getpos 'v'
        local end_pos = vim.fn.getpos '.'

        return {
          start_line = math.min(start_pos[2], end_pos[2]),
          end_line = math.max(start_pos[2], end_pos[2]),
          start_col = is_visual_line_mode and 0 or math.min(start_pos[3], end_pos[3]) - 1,
          end_col = is_visual_line_mode and -1 or math.max(start_pos[3], end_pos[3]),
          mode = mode,
          start_pos = start_pos,
          end_pos = end_pos,
        }
      end

      yank.format_line_range = function(start_line, end_line)
        return start_line == end_line and tostring(start_line) or start_line .. '-' .. end_line
      end

      yank.simulate_yank_highlight = function()
        local bounds = yank.get_visual_bounds()

        local ns = vim.api.nvim_create_namespace 'simulate_yank_highlight'
        vim.highlight.range(0, ns, 'IncSearch', { bounds.start_line - 1, bounds.start_col }, { bounds.end_line - 1, bounds.end_col }, { priority = 200 })
        vim.defer_fn(function()
          vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        end, 150)
      end

      yank.exit_visual_mode = function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
      end

      yank.yank_path = function(path, label)
        vim.fn.setreg('+', path)
        print('Yanked ' .. label .. ' path: ' .. path)
      end

      yank.yank_visual_with_path = function(path, label)
        local bounds = yank.get_visual_bounds()

        local selected_lines = vim.fn.getregion(bounds.start_pos, bounds.end_pos, { type = bounds.mode })
        local selected_text = table.concat(selected_lines, '\n')

        local line_range = yank.format_line_range(bounds.start_line, bounds.end_line)
        local path_with_lines = path .. ':' .. line_range

        local result = path_with_lines .. '\n\n' .. selected_text
        vim.fn.setreg('+', result)

        yank.simulate_yank_highlight()

        yank.exit_visual_mode()

        print('Yanked ' .. label .. ' with lines ' .. line_range)
      end

      _G.yank = yank
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>nohl<CR>";
        options = {
          desc = "Clear search";
        };
      }
      # Yank absolute path
      {
        mode = "n";
        key = "<leader>ya";
        action.__raw = ''
          function()
            yank.yank_path(yank.get_buffer_absolute(), 'absolute')
          end
        '';
        options = {
          desc = "Yank absolute path";
        };
      }
      # Yank relative path
      {
        mode = "n";
        key = "<leader>yr";
        action.__raw = ''
          function()
            yank.yank_path(yank.get_buffer_cwd_relative(), 'relative')
          end
        '';
        options = {
          desc = "Yank relative path";
        };
      }
      # Yank visual selection with absolute path
      {
        mode = "v";
        key = "<leader>ya";
        action.__raw = ''
          function()
            yank.yank_visual_with_path(yank.get_buffer_absolute(), 'absolute')
          end
        '';
        options = {
          desc = "Yank selection with absolute path";
        };
      }
      # Yank visual selection with relative path
      {
        mode = "v";
        key = "<leader>yr";
        action.__raw = ''
          function()
            yank.yank_visual_with_path(yank.get_buffer_cwd_relative(), 'relative')
          end
        '';
        options = {
          desc = "Yank selection with relative path";
        };
      }
    ];
  };
}
