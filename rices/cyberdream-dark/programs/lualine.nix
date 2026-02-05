{
  delib,
  ...
}:
delib.rice {
  name = "cyberdream-dark";
  home.programs.nixvim = {
    plugins.lualine = {
      settings = {
        options = {
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };

          globalstatus = true;
          refresh = {
            statusline = 200;
            tabline = 200;
            winbar = 200;
          };
        };

        # ┌──────────────────────────────────────────────────────────────────────────────┐
        # │ ◎                    readme.md △ main ▴2 ▿1 ⎪●◦◌◦⎪                 2 1  3:9 │
        # └──────────────────────────────────────────────────────────────────────────────┘
        #   a      b                    c                              x    y   z
        sections = {
          # ═══════════════════════════════════════════════════════════════════════════
          # LEFT SIDE: Mode symbol only (ultra minimal)
          # ═══════════════════════════════════════════════════════════════════════════
          lualine_a = [
            {
              __unkeyed-1 = "mode";
              fmt.__raw = ''
                function(str)
                  local mode = vim.fn.mode()
                  local mode_map = {
                    -- Normal/stable states: ◎ (cyan)
                    ['n'] = '◎',
                    ['no'] = '◎',
                    ['nov'] = '◎',
                    ['noV'] = '◎',
                    ['noCTRL-V'] = '◎',
                    ['niI'] = '◎',
                    ['niR'] = '◎',
                    ['niV'] = '◎',
                    ['nt'] = '◎',
                    ['ntT'] = '◎',
                    
                    -- Visual/selection states: ▼ (yellow - matches tmux copy mode)
                    ['v'] = '▼',
                    ['vs'] = '▼',
                    ['V'] = '▼',
                    ['Vs'] = '▼',
                    ['CTRL-V'] = '▼',
                    ['\22'] = '▼',
                    ['\22s'] = '▼',
                    
                    -- Insert/active editing states: ○ (red)
                    ['i'] = '○',
                    ['ic'] = '○',
                    ['ix'] = '○',
                    ['R'] = '○',
                    ['Rc'] = '○',
                    ['Rx'] = '○',
                    ['Rv'] = '○',
                    ['Rvc'] = '○',
                    ['Rvx'] = '○',
                    
                    -- Command/active states: ○ (red)
                    ['c'] = '○',
                    ['cv'] = '○',
                    ['ce'] = '○',
                    ['r'] = '○',
                    ['rm'] = '○',
                    ['r?'] = '○',
                    ['!'] = '○',
                    
                    -- Terminal: ■ (rectangle for terminal mode)
                    ['t'] = '■',
                  }
                  
                  return mode_map[mode] or '◎'
                end
              '';
              color.__raw = ''
                function()
                  local mode = vim.fn.mode()
                  -- Cyan (#5ef1ff) for normal/stable states (◎)
                  local normal_modes = { 'n', 'no', 'nov', 'noV', 'noCTRL-V', 'niI', 'niR', 'niV', 'nt', 'ntT' }
                  for _, m in ipairs(normal_modes) do
                    if mode == m then
                      return { fg = '#5ef1ff', gui = 'bold' }
                    end
                  end
                  
                  -- Yellow (#f1ff5e) for visual states (▼ - matches tmux copy mode)
                  local visual_modes = { 'v', 'vs', 'V', 'Vs', 'CTRL-V', '\22', '\22s' }
                  for _, m in ipairs(visual_modes) do
                    if mode == m then
                      return { fg = '#f1ff5e', gui = 'bold' }
                    end
                  end
                  
                  -- Green (#5eff6c) for terminal mode (■)
                  if mode == 't' then
                    return { fg = '#5eff6c', gui = 'bold' }
                  end
                  
                  -- Red (#ff6e5e) for insert/command/active states (○)
                  return { fg = '#ff6e5e', gui = 'bold' }
                end
              '';
            }
          ];

          # ═══════════════════════════════════════════════════════════════════════════
          # lualine_b: Empty spacer (prevent default branch component)
          # ═══════════════════════════════════════════════════════════════════════════
          lualine_b = [
            {
              __unkeyed-1.__raw = ''
                function()
                  return ""
                end
              '';
            }
          ];

          # ═══════════════════════════════════════════════════════════════════════════
          # CENTER: Filename + Git info (main content area)
          # ═══════════════════════════════════════════════════════════════════════════
          lualine_c = [
            # ─────────────────────────────────────────────────────────────────────────
            # Filename with colored filetype icon (dynamically centered)
            # Example:   readme.md  or   init.lua ●
            # ─────────────────────────────────────────────────────────────────────────
            {
              __unkeyed-1.__raw = ''
                function()
                  local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
                  local filename = vim.fn.expand('%:t')
                  
                  if filename == "" then
                    filename = "[No Name]"
                  end
                  
                  -- Get filetype icon
                  local icon = ""
                  if devicons_ok and filename ~= "[No Name]" then
                    local ext = vim.fn.expand('%:e')
                    icon = devicons.get_icon(filename, ext, { default = true })
                    icon = icon and (icon .. " ") or ""
                  end
                  
                  -- Check for modified status
                  local modified = vim.bo.modified and " ●" or ""
                  local readonly = vim.bo.readonly and " " or ""
                  
                  -- Calculate terminal width and desired centering
                  local win_width = vim.o.columns
                  local content = icon .. filename .. modified .. readonly
                  local content_len = vim.fn.strdisplaywidth(content)
                  
                  -- Estimate left side content: mode (3) + spacing
                  local left_offset = 6
                  
                  -- Calculate padding to center the filename
                  local padding_left = math.max(0, math.floor((win_width - content_len) / 2) - left_offset)
                  local spaces = string.rep(" ", padding_left)
                  
                  return spaces .. content
                end
              '';
              color = {
                fg = "#7b8496"; # Grey for filename
              };
              padding = {
                left = 0;
                right = 1;
              };
            }

            # ─────────────────────────────────────────────────────────────────────────
            # Git branch with △ symbol (always show, no hiding main/master)
            # Example: △ main
            # ─────────────────────────────────────────────────────────────────────────
            {
              __unkeyed-1 = "branch";
              icon = "";
              icons_enabled = false;
              fmt.__raw = ''
                function(str)
                  if str == "" then
                    return ""
                  end
                  return "△ " .. str
                end
              '';
              color = {
                fg = "#5ef1ff"; # Cyan
              };
            }

            # ─────────────────────────────────────────────────────────────────────────
            # Git metrics: added/removed line counts using built-in diff component
            # Example: ▴2 ▿1  (only when changes exist)
            # ─────────────────────────────────────────────────────────────────────────
            {
              __unkeyed-1 = "diff";
              colored = true;
              symbols = {
                added = "▴";
                modified = "▴"; # Treat modified as added for triangle symbol
                removed = "▿";
              };
              diff_color = {
                added = {
                  fg = "#5eff6c"; # Green
                };
                modified = {
                  fg = "#5eff6c"; # Green (same as added)
                };
                removed = {
                  fg = "#ff6e5e"; # Red
                };
              };
            }

            # ─────────────────────────────────────────────────────────────────────────
            # Git status: Jetpack-style staged/unstaged indicators
            # Example: ⎪●◦◌◦⎪  (only when changes exist)
            # ─────────────────────────────────────────────────────────────────────────
            {
              __unkeyed-1.__raw = ''
                function()
                  local status_dict = vim.b.gitsigns_status_dict
                  if not status_dict then
                    return ""
                  end
                  local added = status_dict.added or 0
                  local changed = status_dict.changed or 0
                  local removed = status_dict.removed or 0
                  if (added + changed + removed) == 0 then
                    return ""
                  end
                  local result = {}
                  table.insert(result, '%#LualineGitSeparator#⎪')
                  if added > 0 then
                    table.insert(result, '%#LualineGitStaged#●◦')
                  end
                  if changed > 0 then
                    table.insert(result, '%#LualineGitUnstaged#◌◦')
                  end
                  if removed > 0 then
                    table.insert(result, '%#LualineGitSeparator#▿')
                  end
                  table.insert(result, '%#LualineGitSeparator#⎪')
                  return table.concat(result, "")
                end
              '';
            }
          ];

          # ═══════════════════════════════════════════════════════════════════════════
          # RIGHT SIDE: Diagnostics and progress
          # ═══════════════════════════════════════════════════════════════════════════

          # Diagnostics (conditional - only when present)
          lualine_x = [
            {
              __unkeyed-1 = "diagnostics";
              sources = [ "nvim_lsp" ];
              sections = [
                "error"
                "warn"
              ];
              symbols = {
                error = " ";
                warn = " ";
              };
              diagnostics_color = {
                error = {
                  fg = "#ff6e5e"; # Red
                };
                warn = {
                  fg = "#ffbd5e"; # Orange
                };
              };
            }
          ];

          # lualine_y: Empty (removed LSP/language section)
          lualine_y = [ ];

          # Location indicator: line:column (dimmed grey)
          lualine_z = [
            {
              __unkeyed-1 = "location";
              color = {
                fg = "#7b8496"; # Grey (dimmed)
              };
            }
          ];
        };

        # ═══════════════════════════════════════════════════════════════════════════
        # Inactive windows - minimal display
        # ═══════════════════════════════════════════════════════════════════════════
        inactive_sections = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              color = {
                fg = "#7b8496"; # Grey (muted)
              };
            }
          ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ ];
        };

        tabline = { };

        extensions = [
          "neo-tree"
          "lazy"
          "trouble"
          "oil"
        ];
      };
    };

    # ═════════════════════════════════════════════════════════════════════════════
    # Custom highlight groups for git status and filename components
    # ═════════════════════════════════════════════════════════════════════════════
    extraConfigLua = ''
      -- Set up custom highlight groups for Lualine components
      vim.api.nvim_create_autocmd("ColorScheme", {
      	pattern = "*",
      	callback = function()
      		-- Git status colors for staged/unstaged indicators
      		vim.api.nvim_set_hl(0, "LualineGitStaged", { fg = "#ffbd5e" }) -- Orange for staged
      		vim.api.nvim_set_hl(0, "LualineGitUnstaged", { fg = "#f1ff5e" }) -- Yellow for unstaged
      		vim.api.nvim_set_hl(0, "LualineGitSeparator", { fg = "#7b8496" }) -- Grey for separators

      		-- Filename component colors
      		vim.api.nvim_set_hl(0, "LualineFiletypeIcon", { fg = "#5ea1ff" }) -- Blue for icon (overridden by devicons)
      		vim.api.nvim_set_hl(0, "LualineFilename", { fg = "#7b8496" }) -- Grey for filename
      	end,
      })
    '';
  };
}
