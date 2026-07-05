{ inputs, lib, ... }:
{
  dots.tool._.terminal = {
    description = "Terminal environment: ghostty + herdr + nushell + starship";

    darwin.homebrew.casks = [ "ghostty" ];

    homeManager =
      { pkgs, config, ... }:
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
            keybind = [
              "super+t=ignore"
              "super+d=ignore"
            ];
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
            keys.prefix = "ctrl+b";
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

        home.sessionVariables.FNOX_AGE_KEY_FILE = "${config.home.homeDirectory}/.ssh/${config.home.username}";
      };
  };
}
