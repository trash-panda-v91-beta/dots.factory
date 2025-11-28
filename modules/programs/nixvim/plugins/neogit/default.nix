{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.neogit";

  options.programs.nixvim.plugins.neogit = with delib; {
    enable = boolOption true;
    gitService = allowNull (strOption null);
    openCodeCommit = {
      enable = boolOption true;
      autoGenerate = boolOption false;
      keymap = strOption "<leader>gc";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        plugins.neogit = {
          enable = true;
          settings = lib.mkIf (cfg.gitService != null) {
            git_services = {
              "${cfg.gitService}" = {
                pull_request = "https://${cfg.gitService}/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
                commit = "https://${cfg.gitService}/\${owner}/\${repository}/commit/\${oid}";
                tree = "https://${cfg.gitService}/\${owner}/\${repository}/tree/\${branch_name}";
              };
            };
          };
        };
        keymaps = [
          {
            mode = [ "n" ];
            key = "<leader>gg";
            action = "<cmd>Neogit<cr>";
            options = {
              desc = "Open Neogit";
            };
          }
        ];

        # Add autocommand to trigger OpenCode when entering commit buffer
        autoCmd = lib.optionals cfg.openCodeCommit.enable [
          {
            event = [ "FileType" ];
            pattern = [
              "gitcommit"
              "NeogitCommitMessage"
            ];
            callback = {
              __raw = ''
                function(event)
                  local bufnr = event.buf
                  
                  -- Set buffer-local keymap
                  vim.keymap.set("n", "${cfg.openCodeCommit.keymap}", function()
                    -- Check if buffer is empty (only comments)
                    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                    local has_content = false
                    for _, line in ipairs(lines) do
                      if line ~= "" and not line:match("^%s*#") then
                        has_content = true
                        break
                      end
                    end
                    
                    -- Warn if buffer already has content
                    if has_content then
                      local ok = vim.fn.confirm("Buffer already has content. Replace it?", "&Yes\n&No", 2) == 1
                      if not ok then
                        return
                      end
                    end
                    
                    -- Show loading message
                    vim.notify("Generating commit message with OpenCode...", vim.log.levels.INFO)
                    
                    -- Run OpenCode to generate commit message
                    local opencode_cmd = string.format(
                      '%s run "Generate a git commit message for the staged changes. Only output the commit message text, nothing else. Follow conventional commit format."',
                      "${pkgs.lib.getExe pkgs.local.opencode}"
                    )
                    
                    vim.fn.jobstart(opencode_cmd, {
                      cwd = vim.fn.getcwd(),
                      on_stdout = function(_, data)
                        if data then
                          local result_lines = {}
                          for _, line in ipairs(data) do
                            -- Filter out empty lines and common output artifacts
                            local trimmed = vim.trim(line)
                            if trimmed ~= "" and not trimmed:match("^%[") then
                              table.insert(result_lines, line)
                            end
                          end
                          
                          if #result_lines > 0 then
                            vim.schedule(function()
                              -- Find where to insert (before first comment line)
                              local insert_line = 0
                              for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
                                if line:match("^%s*#") then
                                  insert_line = i - 1
                                  break
                                end
                              end
                              
                              -- Clear existing content if user confirmed
                              if has_content then
                                vim.api.nvim_buf_set_lines(bufnr, 0, insert_line, false, {})
                                insert_line = 0
                              end
                              
                              -- Insert commit message
                              vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, result_lines)
                              
                              -- Add blank line after message
                              if result_lines[#result_lines] ~= "" then
                                vim.api.nvim_buf_set_lines(bufnr, #result_lines, #result_lines, false, { "" })
                              end
                              
                              -- Move cursor to start
                              vim.api.nvim_win_set_cursor(0, { 1, 0 })
                              vim.notify("Commit message generated!", vim.log.levels.INFO)
                            end)
                          end
                        end
                      end,
                      on_stderr = function(_, data)
                        if data then
                          local error_lines = {}
                          for _, line in ipairs(data) do
                            if vim.trim(line) ~= "" then
                              table.insert(error_lines, line)
                            end
                          end
                          if #error_lines > 0 then
                            vim.schedule(function()
                              vim.notify("OpenCode error: " .. table.concat(error_lines, "\n"), vim.log.levels.ERROR)
                            end)
                          end
                        end
                      end,
                      on_exit = function(_, exit_code)
                        if exit_code ~= 0 then
                          vim.schedule(function()
                            vim.notify("OpenCode exited with code: " .. exit_code, vim.log.levels.WARN)
                          end)
                        end
                      end,
                      stdout_buffered = true,
                      stderr_buffered = true,
                    })
                  end, {
                    buffer = bufnr,
                    desc = "Generate AI commit message with OpenCode",
                    silent = true,
                  })
                  
                  ${lib.optionalString cfg.openCodeCommit.autoGenerate ''
                    -- Auto-generate on buffer enter with delay
                    vim.defer_fn(function()
                      -- Only auto-generate if buffer is still valid and empty
                      if not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                      end
                      
                      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                      local is_empty = true
                      for _, line in ipairs(lines) do
                        if line ~= "" and not line:match("^%s*#") then
                          is_empty = false
                          break
                        end
                      end
                      
                      if is_empty then
                        -- Trigger the keymap programmatically
                        vim.api.nvim_buf_call(bufnr, function()
                          vim.cmd("normal ${cfg.openCodeCommit.keymap}")
                        end)
                      end
                    end, 300)
                  ''}
                end
              '';
            };
          }
        ];
      };
    };
}
