{ inputs, lib, ... }:
{
  dots.tool._.terminal = {
    description = "Terminal environment: ghostty + herdr + nushell + starship";

    darwin.homebrew.casks = [ "ghostty" ];

    darwin.environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    homeManager =
      { pkgs, config, lib, ... }:
      let
        # focus-or-create a tab by label; cmd is run in the new pane if provided
        herdrFocusTab =
          label: cmd:
          pkgs.writeShellApplication {
            name = "herdr-focus-tab-${label}";
            runtimeInputs = with pkgs; [
              herdr
              jq
            ];
            text = ''
              ws="$HERDR_ACTIVE_WORKSPACE_ID"
              tab_id=$(herdr tab list --workspace "$ws" | jq -r '.result.tabs[] | select(.label=="${label}") | .tab_id' | head -1)
              if [ -n "$tab_id" ]; then
                herdr tab focus "$tab_id"
              else
                ws_cwd=$(herdr pane list --workspace "$ws" | jq -r '.result.panes[0].cwd // empty')
                cwd="''${ws_cwd:-$HOME}"
${if cmd != null then ''
                result=$(herdr tab create --workspace "$ws" --label "${label}" --cwd "$cwd" --no-focus)
                pane_id=$(echo "$result" | jq -r '.result.root_pane.pane_id')
                herdr pane run "$pane_id" "${cmd}"
                '' else ''
                herdr tab create --workspace "$ws" --label "${label}" --cwd "$cwd" --no-focus >/dev/null
                ''}
                new_tab=$(herdr tab list --workspace "$ws" | jq -r '.result.tabs[] | select(.label=="${label}") | .tab_id' | tail -1)
                herdr tab focus "$new_tab"
              fi
            '';
          };
        herdrFocusNvim = herdrFocusTab "nvim" "nvim";
        herdrFocusPi = herdrFocusTab "pi" "pi";
        herdrFocusSh = herdrFocusTab "sh" null;

        herdrZjumpOpen = pkgs.writeShellApplication {
          name = "herdr-zjump-open";
          runtimeInputs = [ pkgs.herdr ];
          text = ''
            exec herdr plugin pane open --plugin denful.zjump --entrypoint picker
          '';
        };
      in
      {
        programs.ghostty = {
          enable = true;
          package = null; # installed via Homebrew
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          settings = {
            adjust-cell-height = "30%";
            copy-on-select = true;
            cursor-style = "block";
            font-size = 17;
            font-thicken = true;
            mouse-hide-while-typing = true;
            macos-non-native-fullscreen = false;
            macos-option-as-alt = true;
            macos-titlebar-proxy-icon = "hidden";
            title = " ";
            shell-integration-features = "no-title";
            macos-titlebar-style = "hidden";
            window-padding-y = "0,0";
            window-padding-x = 20;
            window-padding-color = "extend";
            window-padding-balance = true;
            window-save-state = "always";
            quit-after-last-window-closed = true;
            keybind = [ ];
          };
        };

        programs.nushell = {
          enable = true;
          settings = {
            show_banner = false;
            edit_mode = "vi";
            cursor_shape = {
              vi_insert = "line";
              vi_normal = "block";
            };
          };
          shellAliases = {
            nu-open = "open";
            macopen = "open";
          };
          environmentVariables = {
            PROMPT_INDICATOR_VI_INSERT = lib.mkForce "";
            PROMPT_INDICATOR_VI_NORMAL = lib.mkForce "";
            DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
          };
          extraLogin = ''
            use std/util "path add"
            path add "/run/current-system/sw/bin"
            path add "/opt/homebrew/bin"
            path add "/opt/homebrew/sbin"
            path add ($env.HOME + "/.nix-profile/bin")
            path add "/nix/var/nix/profiles/default/bin"
            path add "/usr/local/bin"
            path add "/usr/bin"
            path add "/bin"
          '';
        };

        programs.herdr = {
          enable = true;
          settings = {
            onboarding = false;
            terminal.default_shell = lib.getExe pkgs.nushell;
            ui.mouse_scroll_lines = 1;
            keys = {
              prefix = "alt+space";
              switch_tab = "alt+1..9";
              goto = "alt+s";
              copy_mode = [
                "prefix+["
                "ctrl+alt+["
              ];
              edit_scrollback = "prefix+e";
              previous_tab = "prefix+h";
              next_tab = "prefix+l";
              previous_workspace = "prefix+k";
              next_workspace = "prefix+j";
              last_pane = "alt+p";
              open_worktree = "prefix+shift+o";
              remove_worktree = "prefix+alt+d";
              next_agent = "prefix+n";
              previous_agent = "prefix+shift+n";
              command = [
                {
                  key = "prefix+f";
                  type = "shell";
                  command = lib.getExe herdrZjumpOpen;
                  description = "zjump: pick dir via zoxide";
                }
                {
                  key = "alt+e";
                  type = "shell";
                  command = lib.getExe herdrFocusNvim;
                  description = "focus or create nvim tab";
                }
                {
                  key = "alt+a";
                  type = "shell";
                  command = lib.getExe herdrFocusPi;
                  description = "focus or create pi tab";
                }
                {
                  key = "alt+0";
                  type = "shell";
                  command = lib.getExe herdrFocusSh;
                  description = "focus or create shell tab";
                }
              ];
            };
          };
        };

        programs.fzf.enable = true;
        programs.zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };

        programs.carapace = {
          enable = true;
          enableNushellIntegration = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.nix-your-shell = {
          enable = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };

        programs.nushell.environmentVariables.TRANSIENT_PROMPT_COMMAND = inputs.home-manager.lib.hm.nushell.mkNushellInline "^${lib.getExe pkgs.starship} module character";

        programs.starship = {
          enable = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
          enableTransience = true;
          settings = {
            add_newline = true;
            continuation_prompt = "[▸▹ ](dimmed white)";
            format = builtins.concatStringsSep "" [
              "($nix_shell$container$fill$git_metrics\n)$cmd_duration"
              "$hostname$localip$shlvl$shell$env_var$jobs$sudo$username$character"
            ];
            right_format = builtins.concatStringsSep "" [
              "$singularity$kubernetes$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_status"
              "$hg_branch$pijul_channel$docker_context$package$c$cmake$deno$dotnet$elixir$golang$haskell"
              "$java$julia$kotlin$lua$nim$nodejs$python$ruby$rust$swift$terraform$zig$conda$memory_usage"
              "$aws$gcloud$azure$custom$status$os$battery$time"
            ];
            fill.symbol = " ";
            character = {
              format = "$symbol ";
              success_symbol = "[◎](bold italic bright-yellow)";
              error_symbol = "[○](italic purple)";
              vimcmd_symbol = "[■](italic dimmed green)";
            };
            sudo = {
              format = "[$symbol]($style)";
              style = "bold italic bright-purple";
              symbol = "⋈┈";
              disabled = false;
            };
            username = {
              style_user = "bright-yellow bold italic";
              format = "[⭘ $user]($style) ";
              show_always = false;
            };
            directory = {
              home_symbol = "⌂";
              truncation_length = 2;
              truncation_symbol = "□ ";
              read_only = " ◈";
              style = "italic blue";
              format = "[$path]($style)[$read_only]($read_only_style)";
              repo_root_style = "bold blue";
              repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△](bold bright-blue)";
            };
            cmd_duration.format = "[◄ $duration ](italic white)";
            localip = {
              ssh_only = true;
              format = " ◯[$localipv4](bold magenta)";
              disabled = false;
            };
            time = {
              disabled = false;
              format = "[ $time]($style)";
              time_format = "%R";
              style = "italic dimmed white";
            };
            battery = {
              format = "[ $percentage $symbol]($style)";
              full_symbol = "█";
              charging_symbol = "[↑](italic bold green)";
              discharging_symbol = "↓";
              display = [
                {
                  threshold = 20;
                  style = "italic bold red";
                }
                {
                  threshold = 60;
                  style = "italic dimmed bright-purple";
                }
              ];
            };
            git_branch = {
              format = " [$branch(:$remote_branch)]($style)";
              symbol = "[△](bold italic bright-blue)";
              style = "italic bright-blue";
              truncation_length = 11;
              ignore_branches = [
                "main"
                "master"
              ];
              only_attached = true;
            };
            git_metrics = {
              format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
              added_style = "italic dimmed green";
              deleted_style = "italic dimmed red";
              disabled = false;
            };
            git_status = {
              style = "bold italic bright-blue";
              format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
              conflicted = "[◪◦](italic bright-magenta)";
              ahead = "[▴│[\${count}](bold white)│](italic green)";
              behind = "[▿│[\${count}](bold white)│](italic red)";
              untracked = "[◌◦](italic bright-yellow)";
              modified = "[●◦](italic yellow)";
              staged = "[▪┤[\${count}](bold white)│](italic bright-cyan)";
              deleted = "[✕](italic red)";
            };
            nix_shell = {
              style = "bold italic dimmed blue";
              symbol = "✶";
              format = "[\${symbol} nix⎪\${state}⎪]($style) [\${name}](italic dimmed white)";
              impure_msg = "[⌽](bold dimmed red)";
              pure_msg = "[⌾](bold dimmed green)";
            };
            aws.disabled = true;
            nodejs = {
              format = " [node](italic) [◫ (\${version})](bold bright-green)";
              detect_files = [
                "package-lock.json"
                "yarn.lock"
              ];
              detect_extensions = [ ];
            };
            python = {
              format = " [py](italic) [\${symbol}\${version}]($style)";
              symbol = "[⌉](bold bright-blue)⌊ ";
              style = "bold bright-yellow";
            };
            rust = {
              format = " [rs](italic) [\${symbol}\${version}]($style)";
              symbol = "⊃ ";
              style = "bold red";
            };
          };
        };

        programs.yazi = {
          enable = true;
          shellWrapperName = "y";
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
          enableZshIntegration = true;
        };

        home.packages = [ pkgs.herdr-zjump ];

        # Register herdr-zjump with herdr's plugin registry. `plugin link` talks
        # to the running herdr server via socket; if herdr isn't running (fresh
        # boot, first activation), this fails silently and the user re-runs it
        # manually. Also cleans up prior herdr-plus / scratch-dev registrations.
        home.activation.linkHerdrZjump = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD ${lib.getExe pkgs.herdr} plugin unlink cloudmanic.herdr-plus 2>/dev/null || true
          $DRY_RUN_CMD ${lib.getExe pkgs.herdr} plugin unlink you.zjump 2>/dev/null || true
          $DRY_RUN_CMD ${lib.getExe pkgs.herdr} plugin unlink denful.zjump 2>/dev/null || true
          $DRY_RUN_CMD ${lib.getExe pkgs.herdr} plugin link ${pkgs.herdr-zjump} 2>/dev/null || \
            echo "herdr-zjump: link deferred (is herdr running? run 'herdr plugin link ${pkgs.herdr-zjump}')"
        '';

        home.sessionVariables.FNOX_AGE_KEY_FILE = "${config.home.homeDirectory}/.ssh/${config.home.username}";
        home.sessionVariables.EDITOR = "nvim";
        home.sessionVariables.VISUAL = "nvim";
      };
  };
}
