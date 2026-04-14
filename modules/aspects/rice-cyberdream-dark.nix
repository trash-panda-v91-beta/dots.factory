{ ... }:
let
  riceDir = ../rice/cyberdream-dark;
in
{
  dots.rice-cyberdream-dark =
    { user, ... }:
    {
      description = "Cyberdream Dark color scheme for all programs";

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.jetbrains-mono ];

          programs.ghostty.settings = {
            background-opacity = 0.95;
            background-blur-radius = 30;
            font-family = "JetBrains Mono";
            theme = "cyberdream-dark";
          };
          programs.ghostty.themes."cyberdream-dark" = {
            palette = [
              "0=#16181a"
              "1=#ff6e5e"
              "2=#5eff6c"
              "3=#f1ff5e"
              "4=#5ea1ff"
              "5=#bd5eff"
              "6=#5ef1ff"
              "7=#ffffff"
              "8=#3c4048"
              "9=#ff6e5e"
              "10=#5eff6c"
              "11=#f1ff5e"
              "12=#5ea1ff"
              "13=#bd5eff"
              "14=#5ef1ff"
              "15=#ffffff"
            ];
            background = "#16181a";
            foreground = "#ffffff";
            cursor-color = "#ffffff";
            selection-background = "#3c4048";
            selection-foreground = "#ffffff";
          };

          programs.nixvim.colorschemes.cyberdream = {
            enable = true;
            settings = {
              borderless_picker = true;
              cache = true;
              hide_fillchars = true;
              italic_comments = true;
              terminal_colors = true;
              transparent = true;
              variant = "default";
            };
          };

          programs.nixvim.highlight = {
            WhichKey = {
              fg = "#5ef1ff";
            };
            WhichKeyBorder = {
              fg = "#7b8496";
            };
            WhichKeyDesc = {
              fg = "#ffffff";
            };
            WhichKeyGroup = {
              fg = "#ff5ef1";
            };
            WhichKeyIcon = {
              fg = "#5ea1ff";
            };
            WhichKeyIconAzure = {
              fg = "#5ea1ff";
            };
            WhichKeyIconBlue = {
              fg = "#5ea1ff";
            };
            WhichKeyIconCyan = {
              fg = "#5ef1ff";
            };
            WhichKeyIconGreen = {
              fg = "#5eff6c";
            };
            WhichKeyIconGrey = {
              fg = "#7b8496";
            };
            WhichKeyIconOrange = {
              fg = "#ffbd5e";
            };
            WhichKeyIconPurple = {
              fg = "#bd5eff";
            };
            WhichKeyIconRed = {
              fg = "#ff6e5e";
            };
            WhichKeyIconYellow = {
              fg = "#f1ff5e";
            };
            WhichKeyNormal = {
              fg = "#ffffff";
              bg = "none";
            };
            WhichKeySeparator = {
              fg = "#7b8496";
            };
            WhichKeyTitle = {
              fg = "#5ef1ff";
              bold = true;
            };
            WhichKeyValue = {
              fg = "#7b8496";
            };
          };

          programs.nixvim.plugins.lualine.settings = {
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
            sections = {
              lualine_a = [
                {
                  __unkeyed-1 = "mode";
                  fmt.__raw = ''
                    function(str)
                      local mode = vim.fn.mode()
                      local mode_map = {
                        ['n'] = '◎', ['no'] = '◎', ['nov'] = '◎', ['noV'] = '◎',
                        ['noCTRL-V'] = '◎', ['niI'] = '◎', ['niR'] = '◎', ['niV'] = '◎',
                        ['nt'] = '◎', ['ntT'] = '◎',
                        ['v'] = '▼', ['vs'] = '▼', ['V'] = '▼', ['Vs'] = '▼',
                        ['CTRL-V'] = '▼', ['\22'] = '▼', ['\22s'] = '▼',
                        ['i'] = '○', ['ic'] = '○', ['ix'] = '○',
                        ['R'] = '○', ['Rc'] = '○', ['Rx'] = '○', ['Rv'] = '○',
                        ['Rvc'] = '○', ['Rvx'] = '○',
                        ['c'] = '○', ['cv'] = '○', ['ce'] = '○',
                        ['r'] = '○', ['rm'] = '○', ['r?'] = '○', ['!'] = '○',
                        ['t'] = '■',
                      }
                      return mode_map[mode] or '◎'
                    end
                  '';
                  color.__raw = ''
                    function()
                      local mode = vim.fn.mode()
                      local normal_modes = { 'n', 'no', 'nov', 'noV', 'noCTRL-V', 'niI', 'niR', 'niV', 'nt', 'ntT' }
                      for _, m in ipairs(normal_modes) do
                        if mode == m then return { fg = '#5ef1ff', gui = 'bold' } end
                      end
                      local visual_modes = { 'v', 'vs', 'V', 'Vs', 'CTRL-V', '\22', '\22s' }
                      for _, m in ipairs(visual_modes) do
                        if mode == m then return { fg = '#f1ff5e', gui = 'bold' } end
                      end
                      if mode == 't' then return { fg = '#5eff6c', gui = 'bold' } end
                      return { fg = '#ff6e5e', gui = 'bold' }
                    end
                  '';
                }
              ];
              lualine_b = [
                { __unkeyed-1.__raw = ''function() return "" end''; }
              ];
              lualine_c = [
                {
                  __unkeyed-1.__raw = ''
                    function()
                      local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
                      local filename = vim.fn.expand('%:t')
                      if filename == "" then filename = "[No Name]" end
                      local icon = ""
                      if devicons_ok and filename ~= "[No Name]" then
                        local ext = vim.fn.expand('%:e')
                        icon = devicons.get_icon(filename, ext, { default = true })
                        icon = icon and (icon .. " ") or ""
                      end
                      local modified = vim.bo.modified and " ●" or ""
                      local readonly = vim.bo.readonly and " " or ""
                      local win_width = vim.o.columns
                      local content = icon .. filename .. modified .. readonly
                      local content_len = vim.fn.strdisplaywidth(content)
                      local left_offset = 6
                      local padding_left = math.max(0, math.floor((win_width - content_len) / 2) - left_offset)
                      local spaces = string.rep(" ", padding_left)
                      return spaces .. content
                    end
                  '';
                  color = {
                    fg = "#7b8496";
                  };
                  padding = {
                    left = 0;
                    right = 1;
                  };
                }
                {
                  __unkeyed-1 = "branch";
                  icon = "";
                  icons_enabled = false;
                  fmt.__raw = ''
                    function(str)
                      if str == "" then return "" end
                      return "△ " .. str
                    end
                  '';
                  color = {
                    fg = "#5ef1ff";
                  };
                }
                {
                  __unkeyed-1 = "diff";
                  colored = true;
                  symbols = {
                    added = "▴";
                    modified = "▴";
                    removed = "▿";
                  };
                  diff_color = {
                    added = {
                      fg = "#5eff6c";
                    };
                    modified = {
                      fg = "#5eff6c";
                    };
                    removed = {
                      fg = "#ff6e5e";
                    };
                  };
                }
                {
                  __unkeyed-1.__raw = ''
                    function()
                      local status_dict = vim.b.gitsigns_status_dict
                      if not status_dict then return "" end
                      local added = status_dict.added or 0
                      local changed = status_dict.changed or 0
                      local removed = status_dict.removed or 0
                      if (added + changed + removed) == 0 then return "" end
                      local result = {}
                      table.insert(result, '%#LualineGitSeparator#⎪')
                      if added > 0 then table.insert(result, '%#LualineGitStaged#●◦') end
                      if changed > 0 then table.insert(result, '%#LualineGitUnstaged#◌◦') end
                      if removed > 0 then table.insert(result, '%#LualineGitSeparator#▿') end
                      table.insert(result, '%#LualineGitSeparator#⎪')
                      return table.concat(result, "")
                    end
                  '';
                }
              ];
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
                      fg = "#ff6e5e";
                    };
                    warn = {
                      fg = "#ffbd5e";
                    };
                  };
                }
              ];
              lualine_y = [ ];
              lualine_z = [
                {
                  __unkeyed-1 = "location";
                  color = {
                    fg = "#7b8496";
                  };
                }
              ];
            };
            inactive_sections = {
              lualine_a = [ ];
              lualine_b = [ ];
              lualine_c = [
                {
                  __unkeyed-1 = "filename";
                  color = {
                    fg = "#7b8496";
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

          programs.nixvim.extraConfigLua = ''
            vim.api.nvim_create_autocmd("ColorScheme", {
            	pattern = "*",
            	callback = function()
            		vim.api.nvim_set_hl(0, "LualineGitStaged", { fg = "#ffbd5e" })
            		vim.api.nvim_set_hl(0, "LualineGitUnstaged", { fg = "#f1ff5e" })
            		vim.api.nvim_set_hl(0, "LualineGitSeparator", { fg = "#7b8496" })
            		vim.api.nvim_set_hl(0, "LualineFiletypeIcon", { fg = "#5ea1ff" })
            		vim.api.nvim_set_hl(0, "LualineFilename", { fg = "#7b8496" })
            	end,
            })
          '';

          programs.k9s = {
            skins.cyberdream = riceDir + "/programs/k9s/skin.yaml";
            settings.k9s.skin = "cyberdream";
          };

          programs.opencode = {
            themes.cyberdream = riceDir + "/programs/opencode/cyberdream.json";
            tui.theme = "cyberdream";
          };

          programs.yazi.theme = {
            manager = {
              border_style.fg = "#3c4048";
              cwd.fg = "#5ef1ff";
              find_keyword = {
                bold = true;
                fg = "#5eff6c";
              };
              find_position.fg = "#ffffff";
              hovered = {
                bg = "#7b8496";
                bold = true;
                fg = "#ffffff";
              };
              marker_copied = {
                bg = "#f1ff5e";
                fg = "#f1ff5e";
              };
              marker_cut = {
                bg = "#ff6e5e";
                fg = "#ff6e5e";
              };
              marker_selected = {
                bg = "#3c4048";
                fg = "#5eff6c";
              };
              preview_hovered = {
                bg = "#3c4048";
                bold = true;
                fg = "#ffffff";
              };
              tab_active = {
                bg = "#5ea1ff";
                fg = "#16181a";
              };
              tab_inactive = {
                bg = "#3c4048";
                fg = "#ffffff";
              };
              count_selected = {
                bg = "#5eff6c";
                fg = "#16181a";
              };
              count_copied = {
                bg = "#f1ff5e";
                fg = "#16181a";
              };
              count_cut = {
                bg = "#ff6e5e";
                fg = "#16181a";
              };
            };
            status = {
              mode_normal = {
                bg = "#5ea1ff";
                bold = true;
                fg = "#16181a";
              };
              mode_select = {
                bg = "#5eff6c";
                bold = true;
                fg = "#16181a";
              };
              mode_unset = {
                bg = "#ff5ef1";
                bold = true;
                fg = "#16181a";
              };
              permissions_r.fg = "#f1ff5e";
              permissions_s.fg = "#5ef1ff";
              permissions_t.fg = "#5ea1ff";
              permissions_w.fg = "#ff6e5e";
              permissions_x.fg = "#5eff6c";
              progress_error = {
                bg = "#16181a";
                fg = "#ff6e5e";
              };
              progress_label = {
                bg = "#16181a";
                fg = "#ffffff";
              };
              progress_normal = {
                bg = "#16181a";
                fg = "#ffffff";
              };
              separator_style = {
                bg = "#3c4048";
                fg = "#3c4048";
              };
            };
            input = {
              border.fg = "#5ea1ff";
              selected.bg = "#7b8496";
              title.fg = "#ffffff";
              value.fg = "#ffffff";
            };
            select = {
              active.fg = "#bd5eff";
              border.fg = "#5ea1ff";
              inactive.fg = "#ffffff";
            };
            completion = {
              active = {
                bg = "#7b8496";
                fg = "#bd5eff";
              };
              border.fg = "#5ea1ff";
              inactive.fg = "#ffffff";
            };
            help = {
              desc.fg = "#ffffff";
              footer.fg = "#ffffff";
              hovered = {
                bg = "#7b8496";
                fg = "#ffffff";
              };
              on.fg = "#bd5eff";
              run.fg = "#5ef1ff";
            };
            tasks = {
              border.fg = "#5ea1ff";
              hovered = {
                bg = "#7b8496";
                fg = "#ffffff";
              };
              title.fg = "#ffffff";
            };
            which = {
              cand.fg = "#5ef1ff";
              desc.fg = "#ffffff";
              mask.bg = "#3c4048";
              rest.fg = "#ff5ef1";
              separator_style.fg = "#7b8496";
            };
            filetype.rules = [
              {
                fg = "#5ef1ff";
                mime = "image/*";
              }
              {
                fg = "#f1ff5e";
                mime = "video/*";
              }
              {
                fg = "#f1ff5e";
                mime = "audio/*";
              }
              {
                fg = "#bd5eff";
                mime = "application/zip";
              }
              {
                fg = "#bd5eff";
                mime = "application/gzip";
              }
              {
                fg = "#bd5eff";
                mime = "application/x-tar";
              }
              {
                fg = "#bd5eff";
                mime = "application/x-bzip";
              }
              {
                fg = "#bd5eff";
                mime = "application/x-bzip2";
              }
              {
                fg = "#bd5eff";
                mime = "application/x-7z-compressed";
              }
              {
                fg = "#bd5eff";
                mime = "application/x-rar";
              }
              {
                fg = "#bd5eff";
                mime = "application/xz";
              }
              {
                fg = "#5eff6c";
                mime = "application/doc";
              }
              {
                fg = "#5eff6c";
                mime = "application/pdf";
              }
              {
                fg = "#5eff6c";
                mime = "application/rtf";
              }
              {
                fg = "#5eff6c";
                mime = "application/vnd.*";
              }
              {
                bold = true;
                fg = "#5ea1ff";
                mime = "inode/directory";
              }
              {
                fg = "#ffffff";
                mime = "*";
              }
            ];
          };

          # tmux cyberdream theme
          programs.tmux.plugins = with pkgs.tmuxPlugins; [
            {
              plugin = catppuccin;
              extraConfig = ''
                set -g @catppuccin_flavor 'cyberdream'
                set -g @catppuccin_status_background "none"
                set -g @catppuccin_window_status_style "none"
                set -g @catppuccin_pane_status_enabled "off"
                set -g @catppuccin_pane_border_status "off"
              '';
            }
          ];
          programs.tmux.extraConfig = ''
            set -g @cyberdream_cyan "#5ef1ff"
            set -g @cyberdream_red "#ff6e5e"
            set -g @cyberdream_yellow "#f1ff5e"
            set -g @cyberdream_green "#5eff6c"
            set -g @cyberdream_grey "#7b8496"
            set -g @cyberdream_overlay "#3c4048"
            set -g @cyberdream_bg "#16181a"
            set -g @cyberdream_peach "#ffbd5e"
            set -g status-position top
            set -g status-style "bg=default"
            set -g status-justify "absolute-centre"
            set -g status-left-length 100
            set -g status-left ""
            set -ga status-left "#{?client_prefix,#[fg=#{@cyberdream_red}]#[bold]○ #[nobold],#{?pane_in_mode,#[fg=#{@cyberdream_yellow}]#[bold]▼ #[nobold],#[fg=#{@cyberdream_cyan}]#[bold]◎ #[nobold]}}"
            set -ga status-left "#[fg=#{@cyberdream_yellow}]#[bold]#S#[nobold]"
            set -ga status-left "#{?#{!=:#{b:pane_current_path},#S}, #[fg=#{@cyberdream_overlay}]│ #[fg=#{@cyberdream_grey}]#{b:pane_current_path},}"
            set -ga status-left "#[fg=#{@cyberdream_red}]#{?window_zoomed_flag,  ▪,}"
            set -g status-right-length 60
            set -g status-right "#{?#{>:#{session_windows},1},#W,}"
            setw -g pane-border-format ""
            setw -g pane-active-border-style "bg=#{@cyberdream_bg},fg=#{@cyberdream_overlay}"
            setw -g pane-border-style "bg=#{@cyberdream_bg},fg=#{@cyberdream_overlay}"
            setw -g pane-border-lines single
            set -g window-status-format "#{?#{>:#{session_windows},1},#I,}"
            set -g window-status-style "fg=#{@cyberdream_grey}"
            set -g window-status-current-format "#{?#{>:#{session_windows},1},#I,}"
            set -g window-status-current-style "fg=#{@cyberdream_cyan}"
            set -g window-status-separator " #[fg=#{@cyberdream_overlay}]│ "
          '';
        };
    };
}
