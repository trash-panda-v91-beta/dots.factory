{ dots, ... }:
{
  dots.tool._.git.includes = [ dots.tool._.git._.git-octo ];
  dots.tool._.git._.git-octo.homeManager =
    { pkgs, ... }:
    {
      programs.nixvim = {
        extraPackages = [
          pkgs.gh
        ];
        plugins.octo = {
          enable = true;
          lazyLoad.settings = {
            cmd = [ "Octo" ];
            ft = "octo";
          };
          settings = {
            enable_builtin = true;
            default_to_projects_v2 = true;
            default_merge_method = "squash";
            picker.__raw = "'default'";
            picker_config = {
              use_emojis = true;
            };
            commands = {
              pr = {
                auto.__raw = ''
                  function()
                    local gh = require("octo.gh")
                    local picker = require("octo.picker")
                    local utils = require("octo.utils")

                    local buffer = utils.get_current_buffer()

                    local auto_merge = function(number)
                      local cb = function()
                        utils.info("This PR will be auto-merged")
                      end
                      local opts = { cb = cb }
                      gh.pr.merge({ number, auto = true, squash = true, opts = opts })
                    end

                    if not buffer or not buffer:isPullRequest() then
                      picker.prs({
                        cb = function(selected)
                          auto_merge(selected.obj.number)
                        end,
                      })
                    elseif buffer:isPullRequest() then
                      auto_merge(buffer.node.number)
                    end
                  end
                '';
                update.__raw = ''
                  function()
                    local gh = require("octo.gh")
                    local picker = require("octo.picker")
                    local utils = require("octo.utils")

                    local buffer = utils.get_current_buffer()

                    local update_branch = function(number)
                      local cb = function()
                        utils.info("PR branch updated with rebase")
                      end
                      local opts = { cb = cb }
                      gh.pr.update_branch({ number, rebase = true, opts = opts })
                    end

                    if not buffer or not buffer:isPullRequest() then
                      picker.prs({
                        cb = function(selected)
                          update_branch(selected.obj.number)
                        end,
                      })
                    elseif buffer:isPullRequest() then
                      update_branch(buffer.node.number)
                    end
                  end
                '';
                approve.__raw = ''
                  function()
                    local gh = require("octo.gh")
                    local picker = require("octo.picker")
                    local utils = require("octo.utils")

                    local buffer = utils.get_current_buffer()

                    local approve_pr = function(number)
                      local cb = function()
                        utils.info("PR approved")
                      end
                      local opts = { cb = cb }
                      gh.pr.review({ number, approve = true, opts = opts })
                    end

                    if not buffer or not buffer:isPullRequest() then
                      picker.prs({
                        cb = function(selected)
                          approve_pr(selected.obj.number)
                        end,
                      })
                    elseif buffer:isPullRequest() then
                      approve_pr(buffer.node.number)
                    end
                  end
                '';
              };
            };
            # Remap builtin keymaps to match our structure
            mappings = {
              issue = {
                open_in_browser = {
                  lhs = "<localleader>gb";
                  desc = "go to browser";
                };
                copy_url = {
                  lhs = "<localleader>yu";
                  desc = "yank URL";
                };
              };
              pull_request = {
                open_in_browser = {
                  lhs = "<localleader>gb";
                  desc = "go to browser";
                };
                copy_url = {
                  lhs = "<localleader>yu";
                  desc = "yank URL";
                };
                checkout_pr = {
                  lhs = "<localleader>gc";
                  desc = "go checkout";
                };
                merge_pr = {
                  lhs = "<localleader>mm";
                  desc = "merge";
                };
                squash_and_merge_pr = {
                  lhs = "<localleader>ms";
                  desc = "squash and merge";
                };
                rebase_and_merge_pr = {
                  lhs = "<localleader>mr";
                  desc = "rebase and merge";
                };
              };
              review_thread = {
                goto_issue = {
                  lhs = "<localleader>gi";
                  desc = "go to issue";
                };
              };
              review_diff = {
                goto_file = {
                  lhs = "<localleader>gf";
                  desc = "go to file";
                };
              };
              repo = {
                open_in_browser = {
                  lhs = "<localleader>gb";
                  desc = "go to browser";
                };
                copy_url = {
                  lhs = "<localleader>yu";
                  desc = "yank URL";
                };
              };
            };
          };
        };
        # Global keymaps: Octo entry points modelled on gh-dash sections.
        keymaps = [
          {
            mode = "n";
            key = "<leader>op";
            action.__raw = "function() require('octo.picker').prs() end";
            options.desc = "Open PRs";
          }
          {
            mode = "n";
            key = "<leader>or";
            action = "<cmd>Octo search is:pr is:open review-requested:@me<cr>";
            options.desc = "PRs needing my review";
          }
          {
            mode = "n";
            key = "<leader>oI";
            action = "<cmd>Octo search is:pr is:open involves:@me -author:@me<cr>";
            options.desc = "PRs I'm involved in";
          }
          {
            mode = "n";
            key = "<leader>om";
            action = "<cmd>Octo search is:pr is:open author:@me<cr>";
            options.desc = "My open PRs";
          }
          {
            mode = "n";
            key = "<leader>oi";
            action.__raw = "function() require('octo.picker').issues() end";
            options.desc = "Open Issues";
          }
          {
            mode = "n";
            key = "<leader>on";
            action = "<cmd>Octo notification list<cr>";
            options.desc = "Notifications";
          }
          {
            mode = "n";
            key = "<leader>ot";
            action.__raw = ''
              function()
                vim.cmd('tabnew')
                require('octo.picker').prs()
              end
            '';
            options.desc = "Open Octo tab (dedicated PR workspace)";
          }
        ];
        # Add clue groups for octo buffers via mini.clue's buffer-scoped triggers.
        # Custom octo-specific mappings that aren't in octo's builtins.
        autoGroups.octo_extra_maps.clear = true;
        autoCmd = [
          {
            event = "FileType";
            pattern = "octo";
            group = "octo_extra_maps";
            callback.__raw = ''
              function(event)
                local localleader = vim.g.maplocalleader or ' '
                -- Custom commands (not in octo builtins)
                -- Merge: auto-merge
                vim.keymap.set('n', localleader .. 'ma', '<cmd>Octo pr auto<cr>', {
                  buffer = event.buf,
                  desc = 'Auto-merge'
                })

                -- Update branch with rebase (single key)
                vim.keymap.set('n', localleader .. 'u', '<cmd>Octo pr update<cr>', {
                  buffer = event.buf,
                  desc = 'Update branch (rebase)'
                })

                -- Remove <localleader>vp (old Review: Approve key)

                -- close octo buffer
                vim.keymap.set('n', 'q', '<cmd>bd<cr>', {
                  buffer = event.buf,
                  desc = 'Close'
                })

                -- PR: reload buffer (r, matches gh-dash `r`)
                vim.keymap.set('n', 'r', '<cmd>Octo pr reload<cr>', {
                  buffer = event.buf,
                  desc = 'Reload PR buffer'
                })

                -- Review: approve PR (moved to <localleader>ra)
                vim.keymap.set('n', localleader .. 'ra', function()
                  vim.cmd('Octo pr approve')
                  vim.defer_fn(function()
                    vim.cmd('Octo pr reload')
                  end, 400)
                end, {
                  buffer = event.buf,
                  desc = 'Approve PR (then reload)'
                })

                -- Reviewer: add reviewer (<localleader>ar)
                vim.keymap.set('n', localleader .. 'ar', '<cmd>Octo reviewer add<cr>', {
                  buffer = event.buf,
                  desc = 'Add Reviewer'
                })

                -- Yank: copy SHA (not in octo builtins)
                vim.keymap.set('n', localleader .. 'ys', function()
                  local utils = require('octo.utils')
                  local buffer = utils.get_current_buffer()
                  if buffer and buffer.node and buffer.node.headRefOid then
                    vim.fn.setreg('+', buffer.node.headRefOid)
                    utils.info('Copied SHA: ' .. buffer.node.headRefOid)
                  end
                end, {
                  buffer = event.buf,
                  desc = 'Yank SHA'
                })

                -- Shared with gh-dash: a=approve, M=auto-merge, A=label approval, R=label robocat
                local pr_action = function(fn)
                  return function()
                    local utils = require('octo.utils')
                    local buf = utils.get_current_buffer()
                    if not buf or not buf:isPullRequest() then return end
                    fn(buf)
                  end
                end

                vim.keymap.set('n', 'o', '<localleader>gb', { buffer = event.buf, remap = true, desc = 'Open in browser' })

                vim.keymap.set('n', '<space>v', pr_action(function(buf)
                  vim.system(
                    { 'gh', 'pr', 'review', tostring(buf.node.number), '--approve', '--body', 'LGTM', '--repo', buf.repo },
                    { text = true },
                    function(res)
                      vim.schedule(function()
                        if res.code == 0 then
                          require('octo.utils').info('Approved with LGTM')
                          vim.cmd('Octo pr reload')
                        else
                          require('octo.utils').error(res.stderr or 'Failed to approve')
                        end
                      end)
                    end
                  )
                end), { buffer = event.buf, desc = 'Approve PR + LGTM' })

                vim.keymap.set('n', '<space>M', pr_action(function(buf)
                  vim.cmd('Octo pr auto')
                end), { buffer = event.buf, desc = 'Auto-merge PR' })

                vim.keymap.set('n', '<space>L', pr_action(function(buf)
                  vim.system(
                    { 'gh', 'pr', 'edit', tostring(buf.node.number), '--add-label', 'approval/robocat', '--repo', buf.repo },
                    { text = true },
                    function(res)
                      vim.schedule(function()
                        if res.code == 0 then
                          require('octo.utils').info('Label "approval/robocat" added')
                          vim.cmd('Octo pr reload')
                        else
                          require('octo.utils').error(res.stderr or 'Failed to add label')
                        end
                      end)
                    end
                  )
                end), { buffer = event.buf, desc = 'Label: approval/robocat' })

                -- Comment: reactions moved under <localleader>cr*
                vim.keymap.set('n', localleader .. 'crp', '<cmd>Octo reaction hooray<cr>', { buffer = event.buf, desc = 'React :tada:' })
                vim.keymap.set('n', localleader .. 'crh', '<cmd>Octo reaction heart<cr>', { buffer = event.buf, desc = 'React :heart:' })
                vim.keymap.set('n', localleader .. 'cre', '<cmd>Octo reaction eyes<cr>', { buffer = event.buf, desc = 'React :eyes:' })
                vim.keymap.set('n', localleader .. 'cr+', '<cmd>Octo reaction +1<cr>', { buffer = event.buf, desc = 'React :+1:' })
                vim.keymap.set('n', localleader .. 'cr-', '<cmd>Octo reaction -1<cr>', { buffer = event.buf, desc = 'React :-1:' })
                vim.keymap.set('n', localleader .. 'crr', '<cmd>Octo reaction rocket<cr>', { buffer = event.buf, desc = 'React :rocket:' })
                vim.keymap.set('n', localleader .. 'crl', '<cmd>Octo reaction laugh<cr>', { buffer = event.buf, desc = 'React :laughing:' })
                vim.keymap.set('n', localleader .. 'crc', '<cmd>Octo reaction confused<cr>', { buffer = event.buf, desc = 'React :confused:' })
              end
            '';
          }
        ];
      };
    };
}
