{
  delib,
  pkgs,
  lib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.octo";

  options.programs.nixvim.plugins.octo = with delib; {
    enable = boolOption true;
    defaultToProjectsV2 = boolOption true;
    extraKeymaps = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Extra buffer-local keymaps to add in octo buffers";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        extraPackages = [
          pkgs.gh
        ];
        plugins.octo = {
          enable = true;
          settings = {
            enable_builtin = true;
            default_to_projects_v2 = cfg.defaultToProjectsV2;
            default_merge_method = "squash";
            picker = "snacks";
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
        # Global keymap for opening PR picker
        keymaps = [
          {
            mode = "n";
            key = "<leader>gp";
            action.__raw = ''
              function()
                require('octo.picker').prs()
              end
            '';
            options = {
              desc = "Open PRs";
            };
          }
        ];
        # Add which-key group for octo buffers
        autoGroups.octo_which_key.clear = true;
        autoCmd = [
          {
            event = "FileType";
            pattern = "octo";
            group = "octo_which_key";
            callback = ''
              function(event)
                -- Add octo-specific which-key groups
                local localleader = vim.g.maplocalleader or ' '
                require('which-key').add({
                  { localleader .. 'a', group = 'Assignee', buffer = event.buf },
                  { localleader .. 'ar', name = 'Reviewer', buffer = event.buf }, -- new group for reviewer actions
                  { localleader .. 'c', group = 'Comment', buffer = event.buf },
                  { localleader .. 'cr', name = 'Reaction', buffer = event.buf }, -- reactions under comment
                  { localleader .. 'g', group = 'Goto', buffer = event.buf },
                  { localleader .. 'i', group = 'Issue', buffer = event.buf },
                  { localleader .. 'l', group = 'Label', buffer = event.buf },
                  { localleader .. 'm', group = 'Merge', buffer = event.buf },
                  { localleader .. 'r', group = 'Review', buffer = event.buf }, -- moved review group to r
                  { localleader .. 'y', group = 'Yank', buffer = event.buf },
                  
                  -- Hide unwanted global groups/keymaps that conflict with octo keymaps
                  -- Hide LSP group (conflicts with Label)
                  { localleader .. 'lD', hidden = true, buffer = event.buf },
                  { localleader .. 'li', hidden = true, buffer = event.buf },
                  { localleader .. 'lt', hidden = true, buffer = event.buf },
                  { localleader .. 'ld', hidden = true, buffer = event.buf },
                  -- Hide Code group (conflicts with Comment)
                  { localleader .. 'ca', hidden = true, buffer = event.buf },
                  -- Hide Git group items that aren't octo-related
                  { localleader .. 'gd', hidden = true, buffer = event.buf },
                  { localleader .. 'gD', hidden = true, buffer = event.buf },
                  { localleader .. 'gh', hidden = true, buffer = event.buf },
                  { localleader .. 'gH', hidden = true, buffer = event.buf },
                  { localleader .. 'gL', hidden = true, buffer = event.buf },
                  { localleader .. 'gn', hidden = true, buffer = event.buf },
                })
                
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

                -- PR: reload buffer (<localleader>pr)
                vim.keymap.set('n', localleader .. 'pr', '<cmd>Octo pr reload<cr>', {
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
                
                -- Comment: reactions moved under <localleader>cr*
                vim.keymap.set('n', localleader .. 'crp', '<cmd>Octo reaction hooray<cr>', { buffer = event.buf, desc = 'React :tada:' })
                vim.keymap.set('n', localleader .. 'crh', '<cmd>Octo reaction heart<cr>', { buffer = event.buf, desc = 'React :heart:' })
                vim.keymap.set('n', localleader .. 'cre', '<cmd>Octo reaction eyes<cr>', { buffer = event.buf, desc = 'React :eyes:' })
                vim.keymap.set('n', localleader .. 'cr+', '<cmd>Octo reaction +1<cr>', { buffer = event.buf, desc = 'React :+1:' })
                vim.keymap.set('n', localleader .. 'cr-', '<cmd>Octo reaction -1<cr>', { buffer = event.buf, desc = 'React :-1:' })
                vim.keymap.set('n', localleader .. 'crr', '<cmd>Octo reaction rocket<cr>', { buffer = event.buf, desc = 'React :rocket:' })
                vim.keymap.set('n', localleader .. 'crl', '<cmd>Octo reaction laugh<cr>', { buffer = event.buf, desc = 'React :laughing:' })
                vim.keymap.set('n', localleader .. 'crc', '<cmd>Octo reaction confused<cr>', { buffer = event.buf, desc = 'React :confused:' })

                -- Add extra keymaps from configuration
                ${lib.concatMapStringsSep "\n" (keymap: ''
                  vim.keymap.set('${keymap.mode or "n"}', '${keymap.key}', '${keymap.action}', {
                    buffer = event.buf,
                    desc = '${keymap.desc or ""}'
                  })
                '') cfg.extraKeymaps}
              end
            '';
          }
        ];
      };
    };
}
