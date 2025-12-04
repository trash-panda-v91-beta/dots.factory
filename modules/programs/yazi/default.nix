{
  delib,
  pkgs,
  lib,
  ...
}:
delib.module {
  name = "programs.yazi";

  options.programs.yazi = with delib; {
    enable = boolOption true;
    plugins = attrsOption { };
    extraPackages = listOfOption package [ ];
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      # Calculate final plugins list
      finalPlugins =
        cfg.plugins
        // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          inherit (pkgs.yaziPlugins)
            chmod
            full-border
            git
            jump-to-char
            smart-enter
            smart-filter
            ;
        });
    in
    {
      programs.yazi = {
        enable = true;

        # Enable shell integrations
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;

        package = pkgs.yazi.override {
          extraPackages = cfg.extraPackages ++ [
            pkgs.jq
            pkgs._7zz
            pkgs.fd
            pkgs.ripgrep
            pkgs.fzf
            pkgs.zoxide
          ];
        };

        # Plugins configuration
        plugins = finalPlugins;

        # Init lua for plugin setup
        initLua =
          # Only setup plugins if they exist
          lib.optionalString (lib.hasAttr "full-border" finalPlugins) ''
            -- Setup full-border plugin
            require("full-border"):setup()
          ''
          + lib.optionalString (lib.hasAttr "git" finalPlugins) ''
            -- Setup git plugin
            require("git"):setup()
          ''
          + ''
            -- Cross session yank
            require("session"):setup({
              sync_yanked = true,
            })

            -- Custom linemode for file display
            function Linemode:custom()
              local year = os.date("%Y")
              local time = (self._file.cha.mtime or 0) // 1

              if time > 0 and os.date("%Y", time) == year then
                time = os.date("%b %d %H:%M", time)
              else
                time = time and os.date("%b %d  %Y", time) or ""
              end

              local size = self._file:size()
              return ui.Line(string.format(" %s %s ", size and ya.readable_size(size):gsub(" ", "") or "-", time))
            end

            -- Header with user@hostname
            Header:children_add(function()
              if ya.target_family() ~= "unix" then
                return ui.Line({})
              end
              return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
            end, 500, Header.LEFT)

            -- Filename and symbolic link path
            function Status:name()
              local h = cx.active.current.hovered
              if not h then
                return ui.Span("")
              end

              local linked = ""
              if h.link_to ~= nil then
                linked = " -> " .. tostring(h.link_to)
              end
              return ui.Span(" " .. h.name .. linked)
            end

            -- File Owner
            Status:children_add(function()
              local h = cx.active.current.hovered
              if h == nil or ya.target_family() ~= "unix" then
                return ui.Line({})
              end

              return ui.Line({
                ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
                ui.Span(":"),
                ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
                ui.Span(" "),
              })
            end, 500, Status.RIGHT)

            -- File creation and modified date
            Status:children_add(function()
              local h = cx.active.current.hovered
              local formatted_created = nil
              local formatted_modified = nil

              if h == nil then
                return ui.Line({})
              end

              if h.cha then
                -- Check if timestamps exist and are not near epoch start
                if h.cha.ctime and h.cha.ctime > 86400 then
                  formatted_created = tostring(os.date("%Y-%m-%d %H:%M:%S", math.floor(h.cha.ctime)))
                end

                if h.cha.mtime and h.cha.mtime > 86400 then
                  formatted_modified = tostring(os.date("%Y-%m-%d %H:%M:%S", math.floor(h.cha.mtime)))
                end
              end

              return ui.Line({
                ui.Span(formatted_created or ""):fg("green"),
                ui.Span(" "),
                ui.Span(formatted_modified or ""):fg("blue"),
                ui.Span(" "),
              })
            end, 400, Status.RIGHT)
          '';

        # Keymap configuration
        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "<Esc>" ];
              run = "close";
              desc = "Close the current tab; if it's the last tab, exit the process instead.";
            }
            {
              on = [ "<C-n>" ];
              run = "tab_create --current";
              desc = "Create a new tab with CWD.";
            }
          ]
          ++ lib.optionals (lib.hasAttr "smart-enter" finalPlugins) [
            {
              on = [ "l" ];
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
            {
              on = [ "<Right>" ];
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
          ]
          ++ lib.optionals (lib.hasAttr "chmod" finalPlugins) [
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
              desc = "Chmod on selected files";
            }
          ]
          ++ lib.optionals (lib.hasAttr "jump-to-char" finalPlugins) [
            {
              on = [ "f" ];
              run = "plugin jump-to-char";
              desc = "Jump to char";
            }
          ]
          ++ lib.optionals (lib.hasAttr "smart-filter" finalPlugins) [
            {
              on = [ "F" ];
              run = "plugin smart-filter";
              desc = "Smart filter";
            }
          ];
        };

        # Settings configuration
        settings = {
          log = {
            enabled = true;
          };

          mgr = {
            ratio = [
              1
              3
              4
            ];
            linemode = "custom";
            show_hidden = true;
            show_symlink = true;
            sort_by = "alphabetical";
            sort_dir_first = true;
            sort_reverse = false;
            sort_sensitive = false;
          };

          pick = {
            open_title = "Open with:";
            open_origin = "hovered";
            open_offset = [
              0
              1
              50
              7
            ];
          };

          preview = {
            tab_size = 2;
            max_width = 600;
            max_height = 900;
            image_filter = "triangle";
            image_quality = 75;
            sixel_fraction = 15;
            ueberzug_scale = 1;
            ueberzug_offset = [
              0
              0
              0
              0
            ];
            wrap = "yes";
          };

          tasks = {
            micro_workers = 10;
            macro_workers = 25;
            bizarre_retry = 5;
            image_alloc = 536870912; # 512MB
            image_bound = [
              0
              0
            ];
            suppress_preload = false;
          };

          which = {
            sort_by = "none";
            sort_sensitive = false;
            sort_reverse = false;
          };

          plugin = {
            preloaders = [
              # Image
              {
                mime = "image/vnd.djvu";
                run = "noop";
              }
              {
                mime = "image/*";
                run = "image";
              }
              # Video
              {
                mime = "video/*";
                run = "video";
              }
              # PDF
              {
                mime = "application/pdf";
                run = "pdf";
              }
            ];

            previewers = [
              {
                name = "*/";
                run = "folder";
                sync = true;
              }
              # Code
              {
                mime = "text/*";
                run = "code";
              }
              {
                mime = "*/xml";
                run = "code";
              }
              {
                mime = "*/javascript";
                run = "code";
              }
              # JSON
              {
                mime = "application/json";
                run = "json";
              }
              # Image
              {
                mime = "image/vnd.djvu";
                run = "noop";
              }
              {
                mime = "image/*";
                run = "image";
              }
              # Video
              {
                mime = "video/*";
                run = "video";
              }
              # PDF
              {
                mime = "application/pdf";
                run = "pdf";
              }
              # Archive
              {
                mime = "application/gzip";
                run = "archive";
              }
              # Fallback
              {
                name = "*";
                run = "file";
              }
            ];
          };
        };
      };
    };
}
