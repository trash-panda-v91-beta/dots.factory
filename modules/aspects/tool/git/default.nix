{ ... }:
{
  dots.tool._.git = {
    description = "Git workflow: git, gh, delta + gitsigns, neogit, codediff, octo";

    homeManager =
      { pkgs, config, lib, ... }:
      {
        options.dots.reposDir = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/repos";
          description = "Root directory for all repos (host-specific)";
        };
        config.programs.git = {
          enable = true;
          lfs.enable = true;
          ignores = [
            ".DS_Store"
            ".venv"
            "Thumbs.db"
            ".direnv"
          ];
          settings = {
            core.autocrlf = "input";
            core.editor = "nvim";
            diff.algorithm = "histogram";
            diff.tool = "codediff";
            difftool.codediff.cmd = ''nvim "$LOCAL" "$REMOTE" +"CodeDiff file $LOCAL $REMOTE"'';
            difftool.prompt = false;
            fetch.prune = true;
            help.autocorrect = 10;
            init.defaultBranch = "main";
            merge.conflictStyle = "zdiff3";
            pull.rebase = true;
            push.autoSetupRemote = true;
            rebase.autoStash = true;
          };
          signing = {
            format = "openpgp";
            key = null;
          };
        };

        config.programs.gh = {
          enable = true;
          extensions = [ pkgs.gh-enhance ];
        };
        config.programs.gh-dash = {
          enable = true;
          settings = {
            prSections = [
              {
                title = "Open Pull Requests";
                filters = "is:open";
              }
              {
                title = "Needs My Review";
                filters = "is:open review-requested:@me";
              }
              {
                title = "Involved";
                filters = "is:open involves:@me -author:@me";
              }
            ];
            issuesSections = [
              {
                title = "My Issues";
                filters = "is:open author:@me";
              }
              {
                title = "Assigned";
                filters = "is:open assignee:@me";
              }
            ];
            defaults = {
              preview = {
                open = true;
                width = 65;
              };
              prsLimit = 20;
              issuesLimit = 20;
            };
            repoPaths = {
              "trash-panda-v91-beta/*" = "${config.dots.reposDir}/github.com/trash-panda-v91-beta/*";
            };
            keybindings = {
              universal = [
                {
                  key = "up";
                  builtin = "pageUp";
                }
                {
                  key = "down";
                  builtin = "pageDown";
                }
              ];
              prs = [
                {
                  key = "D";
                  name = "codediff";
                  command = "cd {{.RepoPath}}; nvim -c \"CodeDiff {{.BaseRefName}}\"";
                }
                {
                  key = "O";
                  name = "edit in octo";
                  command = "nvim -c \"Octo pr edit {{.PrNumber}}\"";
                }
                {
                  key = "T";
                  name = "enhance (actions)";
                  command = "gh enhance -R {{.RepoName}} {{.PrNumber}}";
                }
                {
                  key = "M";
                  name = "auto-merge";
                  command = "gh pr merge {{.PrNumber}} --auto --squash --repo {{.RepoName}}";
                }
                {
                  key = "L";
                  name = "label approval/robocat";
                  command = "gh pr edit {{.PrNumber}} --add-label 'approval/robocat' --repo {{.RepoName}}";
                }
              ];
            };
          };
        };

        config.programs.lazygit = {
          enable = true;
          settings = {
            customCommands = [
              {
                key = "o";
                command = "gh pr view {{.SelectedLocalBranch.Name}} --web || gh pr create {{.SelectedLocalBranch.Name}} --web";
                context = "remoteBranches";
              }
            ];
            gui = {
              border = "rounded";
              nerdFontsVersion = 3;
              showIcons = true;
            };
            keybinding.commits = {
              moveDownCommit = "J";
              moveUpCommit = "K";
            };
          };
        };
      };
  };
}
