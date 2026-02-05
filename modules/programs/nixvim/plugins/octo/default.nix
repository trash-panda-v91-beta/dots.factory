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
            callback.__raw = ''
              function(event)
                -- Add octo-specific which-key groups
                local localleader = vim.g.maplocalleader or ' '
                require('which-key').add({
                  { localleader .. 'a', group = 'Assignee', buffer = event.buf },
                  { localleader .. 'c', group = 'Comment', buffer = event.buf },
                  { localleader .. 'g', group = 'Goto', buffer = event.buf },
                  { localleader .. 'i', group = 'Issue', buffer = event.buf },
                  { localleader .. 'l', group = 'Label', buffer = event.buf },
                  { localleader .. 'p', group = 'Pull Request', buffer = event.buf },
                  { localleader .. 'r', group = 'React', buffer = event.buf },
                  { localleader .. 'v', group = 'Review', buffer = event.buf },
                  { localleader .. 'y', group = 'Yank/Copy', buffer = event.buf },
                  
                  -- Hide unwanted global groups/keymaps that conflict with octo keymaps
                  -- Hide LSP group (conflicts with Label)
                  { localleader .. 'lD', hidden = true, buffer = event.buf },
                  { localleader .. 'li', hidden = true, buffer = event.buf },
                  { localleader .. 'lt', hidden = true, buffer = event.buf },
                  { localleader .. 'ld', hidden = true, buffer = event.buf },
                  -- Hide Code group (conflicts with Comment)
                  { localleader .. 'ca', hidden = true, buffer = event.buf },
                  -- Hide Git group items that aren't octo-related
                  { localleader .. 'gb', hidden = true, buffer = event.buf },
                  { localleader .. 'gc', hidden = true, buffer = event.buf },
                  { localleader .. 'gC', hidden = true, buffer = event.buf },
                  { localleader .. 'gd', hidden = true, buffer = event.buf },
                  { localleader .. 'gD', hidden = true, buffer = event.buf },
                  { localleader .. 'gf', hidden = true, buffer = event.buf },
                  { localleader .. 'gh', hidden = true, buffer = event.buf },
                  { localleader .. 'gH', hidden = true, buffer = event.buf },
                  { localleader .. 'gL', hidden = true, buffer = event.buf },
                  { localleader .. 'gn', hidden = true, buffer = event.buf },
                })
                
                -- Auto-merge keymap
                vim.keymap.set('n', localleader .. 'pa', '<cmd>Octo pr auto<cr>', {
                  buffer = event.buf,
                  desc = 'Auto-merge PR'
                })
                
                -- Update branch with rebase keymap
                vim.keymap.set('n', localleader .. 'pu', '<cmd>Octo pr update<cr>', {
                  buffer = event.buf,
                  desc = 'Update branch (rebase)'
                })
                
                -- Open in browser keymap (mirrors <C-b>)
                vim.keymap.set('n', localleader .. 'b', function()
                  local utils = require('octo.utils')
                  local buffer = utils.get_current_buffer()
                  if buffer then
                    utils.open_in_browser(buffer)
                  end
                end, {
                  buffer = event.buf,
                  desc = 'Open in browser'
                })
                
                -- Copy URL keymap (mirrors <C-y>)
                vim.keymap.set('n', localleader .. 'yu', function()
                  local utils = require('octo.utils')
                  local buffer = utils.get_current_buffer()
                  if buffer then
                    utils.copy_url(buffer)
                  end
                end, {
                  buffer = event.buf,
                  desc = 'Copy URL'
                })
                
                -- Copy SHA keymap (mirrors <C-e>)
                vim.keymap.set('n', localleader .. 'ys', function()
                  local utils = require('octo.utils')
                  local buffer = utils.get_current_buffer()
                  if buffer and buffer.node and buffer.node.headRefOid then
                    vim.fn.setreg('+', buffer.node.headRefOid)
                    utils.info('Copied SHA: ' .. buffer.node.headRefOid)
                  end
                end, {
                  buffer = event.buf,
                  desc = 'Copy SHA'
                })
                
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
