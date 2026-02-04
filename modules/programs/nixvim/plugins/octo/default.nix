{
  delib,
  pkgs,
  lib,
  host,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.octo";

  options.programs.nixvim.plugins.octo = with delib; {
    enable = boolOption true;
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
            default_to_projects_v2 = true;
            default_merge_method = "squash";
            picker = "snacks";
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
