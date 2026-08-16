{ ... }:
let
  riceDir = ../../rice/cyberdream-dark;
in
{
  dots.rice._.cyberdream-dark = {
    description = "Cyberdream Dark color scheme for all programs";

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
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

        programs.nixvim.extraConfigLua = ''
          -- Geometry-in-spirit statusline colors + per-mode cursor colors.
          -- Cursor shape comes from tool/nixvim/default.nix guicursor;
          -- statusline content from tool/nixvim/editing.nix mini-statusline.
          local function apply_geometry_hl()
            local set = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

            -- Cursor color per mode. `bg` is the drawn cursor color;
            -- `fg` is the char under the cursor.
            set("GeometryCursorN", { bg = "#f1ff5e", fg = "#16181a" })  -- normal   : bright-yellow
            set("GeometryCursorI", { bg = "#bd5eff", fg = "#16181a" })  -- insert   : purple
            set("GeometryCursorV", { bg = "#ffbd5e", fg = "#16181a" })  -- visual   : orange
            set("GeometryCursorC", { bg = "#5eff6c", fg = "#16181a" })  -- command  : green
            set("GeometryCursorR", { bg = "#ff6e5e", fg = "#16181a" })  -- replace  : red
            set("GeometryCursorT", { bg = "#5ef1ff", fg = "#16181a" })  -- terminal : cyan

            -- Mode glyph (colored, far-left of statusline). Same palette as the
            -- cursor groups but as fg, so it stays legible on the statusline.
            set("GeometryModeN", { fg = "#f1ff5e", bold = true, italic = true })
            set("GeometryModeI", { fg = "#bd5eff", italic = true })
            set("GeometryModeV", { fg = "#ffbd5e", italic = true })
            set("GeometryModeC", { fg = "#5eff6c", italic = true })
            set("GeometryModeR", { fg = "#ff6e5e", italic = true })
            set("GeometryModeT", { fg = "#5ef1ff", italic = true })

            -- Statusline pieces — each with its own italic accent (jetpack-style).
            set("GeometryDir",       { fg = "#5ea1ff", italic = true })
            set("GeometryFile",      { fg = "#5ea1ff", bold = true })
            set("GeometryModified",  { fg = "#f1ff5e", italic = true })
            set("GeometryReadOnly",  { fg = "#ff5ef1", italic = true })
            set("GeometryBranch",    { fg = "#5ea1ff", italic = true })
            set("GeometryBranchSym",  { fg = "#5ea1ff", bold = true, italic = true })
            -- Statusline: repo/path pieces
            set("GeometryTruncBox",   { fg = "#3c4048" })
            set("GeometryRepoRoot",   { fg = "#5ea1ff", bold = true })
            set("GeometryPath",       { fg = "#5ea1ff", italic = true })
            -- Statusline: git status bracket + inline state
            set("GeometryStatusBracket", { fg = "#7b8496" })
            set("GeometryStatusMod",     { fg = "#f1ff5e", italic = true })
            set("GeometryStatusDel",     { fg = "#ff6e5e", italic = true })
            set("GeometryDiffAdd",   { fg = "#5eff6c", italic = true })
            set("GeometryDiffMod",   { fg = "#f1ff5e", italic = true })
            set("GeometryDiffDel",   { fg = "#ff6e5e", italic = true })
            set("GeometryDiagErr",   { fg = "#ff6e5e", bold = true, italic = true })
            set("GeometryDiagWarn",  { fg = "#ffbd5e", italic = true })
            set("GeometryFiletype",  { fg = "#7b8496", italic = true })
            set("GeometryLangRed",    { fg = "#ff6e5e", italic = true })
            set("GeometryLangYellow", { fg = "#f1ff5e", italic = true })
            set("GeometryLangGreen",  { fg = "#5eff6c", italic = true })
            set("GeometryLangBlue",   { fg = "#5ea1ff", italic = true })
            set("GeometryLangPurple", { fg = "#bd5eff", italic = true })

            set("GeometryLocation",  { fg = "#7b8496", italic = true })

            set("MiniStatuslineInactive", { fg = "#7b8496" })

            -- Tabline: geometry-style tabs with raised active/modified buttons.
            -- Active tab pops via bgHighlight; modified overlays yellow across all states.
            set("MiniTablineCurrent",         { fg = "#5ea1ff", bg = "#3c4048", bold = true })
            set("MiniTablineVisible",         { fg = "#ffffff", italic = true })
            set("MiniTablineHidden",          { fg = "#7b8496", italic = true })
            set("MiniTablineModifiedCurrent", { fg = "#f1ff5e", bg = "#3c4048", bold = true, italic = true })
            set("MiniTablineModifiedVisible", { fg = "#f1ff5e", italic = true })
            set("MiniTablineModifiedHidden",  { fg = "#f1ff5e", italic = true })
            set("MiniTablineFill",            { link = "Normal" })
            set("MiniTablineTabpagesection",  { fg = "#16181a", bg = "#bd5eff", bold = true })
            set("MiniTablineTrunc",           { fg = "#7b8496", italic = true })
          end

          -- Apply now (colorscheme is already loaded at extraConfigLua time)
          -- and re-apply if the user swaps colorscheme later.
          apply_geometry_hl()
          vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = apply_geometry_hl,
          })
        '';

        programs.k9s = {
          skins.cyberdream = riceDir + "/programs/k9s/skin.yaml";
          settings.k9s.skin = "cyberdream";
        };

        programs.pi-coding-agent.settings.theme = lib.mkForce "cyberdream";
        home.file."${config.programs.pi-coding-agent.configDir}/themes/cyberdream.json".source =
          riceDir + "/programs/pi/cyberdream.json";
        home.file."${config.programs.pi-coding-agent.configDir}/themes/cyberdream-light.json".source =
          riceDir + "/programs/pi/cyberdream-light.json";
        home.file."${config.programs.pi-coding-agent.configDir}/themes/cyberdream-muted.json".source =
          riceDir + "/programs/pi/cyberdream-muted.json";

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

        programs.vicinae.themes.cyberdream = {
            meta = {
              description = "Cyberdream theme for vicinae";
              inherits = "vicinae-dark";
              name = "Cyberdream";
              variant = "dark";
            };
            colors.accents = { blue = "#5ea1ff"; cyan = "#5ef1ff"; green = "#5eff6c"; magenta = "#ff5ef1"; orange = "#ffbd5e"; purple = "#bd5eff"; red = "#ff6e5e"; yellow = "#f1ff5e"; };
            colors.button.primary = { background = "#3c4048"; foreground = "#ffffff"; };
            colors.button.primary.focus.outline = "#5ea1ff";
            colors.button.primary.hover.background = "#5ea1ff";
            colors.core = { accent = "#5ea1ff"; accent_foreground = "#ffffff"; background = "#16181a"; border = "#3c4048"; foreground = "#ffffff"; secondary_background = "#1e2124"; };
            colors.grid.item.background = "#3c4048";
            colors.grid.item.hover.outline = "#ffffff";
            colors.grid.item.selection.outline = "#ffffff";
            colors.input = { border = "#7b8496"; border_error = "#ff6e5e"; border_focus = "#5ea1ff"; };
            colors.list.item.hover = { background = "#3c4048"; foreground = "#ffffff"; };
            colors.list.item.selection = { background = "#3c4048"; foreground = "#ffffff"; secondary_background = "#3c4048"; secondary_foreground = "#7b8496"; };
            colors.loading = { bar = "#5ea1ff"; spinner = "#5ea1ff"; };
            colors.scrollbars.background = "#7b8496";
            colors.text = { danger = "#ff6e5e"; default = "#ffffff"; muted = "#7b8496"; placeholder = "#3c4048"; success = "#5eff6c"; };
            colors.text.links = { default = "#5ea1ff"; visited = "#ff5ea0"; };
            colors.text.selection = { background = "#5ea1ff"; foreground = "#ffffff"; };
          };

        vicinae.extraSettings.theme.dark.name = "Cyberdream";

        programs.herdr.settings.theme = {
          name = "terminal";
          custom = {
            accent = "#5ea1ff";
            panel_bg = "#16181a";
            surface0 = "#3c4048";
            surface1 = "#7b8496";
            surface_dim = "#1e2124";
            overlay0 = "#7b8496";
            overlay1 = "#ffffff";
            text = "#ffffff";
            subtext0 = "#7b8496";
            mauve = "#bd5eff";
            green = "#5eff6c";
            yellow = "#f1ff5e";
            red = "#ff6e5e";
            blue = "#5ea1ff";
            teal = "#5ef1ff";
            peach = "#ffbd5e";
          };
        };
      };
  };
}
