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
          settings = {
            commit_popup = {
              kind = "floating";
            };
            disable_builtin_notifications = true;
            disable_commit_confirmation = true;
            integrations = {
              diffview = true;
            };
            kind = "floating";
            mappings = {
              status = {
                a = "Stage";
                l = "Toggle";
              };
            };
            popup = {
              kind = "floating";
            };
            preview_buffer = {
              kind = "floating";
            };
            sections = {
              recent = {
                folded = true;
              };
              staged = {
                folded = false;
              };
              stashes = {
                folded = false;
              };
              unmerged = {
                folded = true;
              };
              unpulled = {
                folded = false;
              };
              unstaged = {
                folded = false;
              };
              untracked = {
                folded = false;
              };
            };
          }
          // (lib.optionalAttrs (cfg.gitService != null) {
            git_services = {
              "${cfg.gitService}" = {
                pull_request = "https://${cfg.gitService}/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
                commit = "https://${cfg.gitService}/\${owner}/\${repository}/commit/\${oid}";
                tree = "https://${cfg.gitService}/\${owner}/\${repository}/tree/\${branch_name}";
              };
            };
          });
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
          {
            mode = [ "n" ];
            key = "<leader>gn";
            action.__raw = ''
              function()
                -- Quick git workflow: checkout main, pull, create new branch
                local git = require('neogit.lib.git')
                
                -- Check for uncommitted changes first
                local status_result = git.cli.status.args("--porcelain").call({ await = true })
                if status_result.code == 0 and status_result.stdout and #status_result.stdout > 0 then
                  local has_changes = false
                  for _, line in ipairs(status_result.stdout) do
                    if vim.trim(line) ~= "" then
                      has_changes = true
                      break
                    end
                  end
                  if has_changes then
                    vim.notify("Cannot create branch: you have uncommitted changes. Please commit or stash them first.", vim.log.levels.ERROR)
                    return
                  end
                end
                
                -- Step 1: Detect and checkout main/master
                vim.notify("Switching to main branch...", vim.log.levels.INFO)
                
                -- Get list of local branches using CLI
                local branch_result = git.cli.branch.call({ await = true })
                local branch_list = {}
                if branch_result.code == 0 then
                  for _, line in ipairs(branch_result.stdout) do
                    local branch = line:match("^%*?%s*(.+)$")
                    if branch then 
                      table.insert(branch_list, branch)
                    end
                  end
                end
                
                -- Try main first, fallback to master
                local main_branch = "main"
                local has_main = vim.tbl_contains(branch_list, "main")
                local has_master = vim.tbl_contains(branch_list, "master")
                
                if not has_main and has_master then
                  main_branch = "master"
                elseif not has_main and not has_master then
                  vim.notify("Neither 'main' nor 'master' branch found", vim.log.levels.ERROR)
                  return
                end
                
                local checkout_result = git.cli.checkout.branch(main_branch).call({ await = true })
                if checkout_result.code ~= 0 then
                  local error_msg = "Failed to checkout " .. main_branch
                  if checkout_result.stderr and #checkout_result.stderr > 0 then
                    error_msg = error_msg .. ": " .. table.concat(checkout_result.stderr, "\n")
                  end
                  vim.notify(error_msg, vim.log.levels.ERROR)
                  return
                end
                
                -- Step 2: Pull latest changes
                vim.notify("Pulling latest changes...", vim.log.levels.INFO)
                local pull_result = git.cli.pull.call({ await = true })
                if pull_result.code ~= 0 then
                  local error_msg = "Failed to pull"
                  if pull_result.stderr and #pull_result.stderr > 0 then
                    error_msg = error_msg .. ": " .. table.concat(pull_result.stderr, "\n")
                  end
                  vim.notify(error_msg, vim.log.levels.WARN)
                  -- Continue anyway, user might want to create branch even if pull fails
                end
                
                -- Step 3: Prompt for new branch name using Snacks.input
                require('snacks').input({
                  prompt = "New branch name: ",
                  icon = " ",
                }, function(branch_name)
                  if not branch_name or branch_name == "" then
                    vim.notify("Branch creation cancelled", vim.log.levels.INFO)
                    return
                  end
                  
                  -- Enhanced branch name validation
                  if branch_name:match("[^%w/_.-]") or       -- Basic character check
                     branch_name:match("^-") or              -- No leading dash
                     branch_name:match("%.%.") or            -- No consecutive dots
                     branch_name:match("@{") or              -- No reflog syntax
                     branch_name:match("%.lock$") or         -- No .lock suffix
                     branch_name:match("^%.") or             -- No leading dot
                     branch_name:match("%.$") then           -- No trailing dot
                    vim.notify("Invalid branch name. Use alphanumeric, dash, underscore, slash, and dots. Cannot start with dash or dot.", vim.log.levels.ERROR)
                    return
                  end
                  
                  -- Step 4: Create and checkout new branch
                  vim.notify("Creating branch: " .. branch_name, vim.log.levels.INFO)
                  local create_result = git.cli.checkout.args("-b").branch(branch_name).call({ await = true })
                  
                  if create_result.code == 0 then
                    vim.notify("✓ Created and switched to branch: " .. branch_name, vim.log.levels.INFO)
                    -- Refresh Neogit if it's open
                    pcall(function()
                      require('neogit').refresh()
                    end)
                  else
                    local error_msg = "Failed to create branch"
                    if create_result.stderr and #create_result.stderr > 0 then
                      error_msg = error_msg .. ": " .. table.concat(create_result.stderr, "\n")
                    end
                    vim.notify(error_msg, vim.log.levels.ERROR)
                  end
                end)
              end
            '';
            options = {
              desc = "New branch (main→pull→create)";
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
