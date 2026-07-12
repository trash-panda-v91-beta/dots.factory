{ lib, ... }:
{
  dots.tool._.git = {
    description = "Git workflow: git, gh, lazygit, delta + gitsigns, neogit, codediff, octo, snacks/lazygit";

    homeManager =
      { pkgs, ... }:
      {
        programs.delta.enable = false;
        programs.git = {
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

        programs.gh.enable = true;
        programs.gh-dash = {
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
              "trash-panda-v91-beta/*" = "/Users/I572068/SAPDevelop/repos/personal/*";
            };
            keybindings = {
              universal = [
                { key = "up"; builtin = "pageUp"; }
                { key = "down"; builtin = "pageDown"; }
                { key = "j"; builtin = "down"; }
                { key = "k"; builtin = "up"; }
                { key = "h"; builtin = "prevSection"; }
                { key = "l"; builtin = "nextSection"; }
              ];
              prs = [
                {
                  key = "D";
                  name = "codediff";
                  command = "cd {{.RepoPath}} && nvim -c \"CodeDiff {{.BaseRefName}}...\"";
                }
                {
                  key = "c";
                  name = "edit in octo";
                  command = "nvim -c \"Octo pr edit {{.PrNumber}}\"";
                }
                {
                  key = "v";
                  name = "approve + LGTM";
                  command = "gh pr review {{.PrNumber}} --approve --body 'LGTM' --repo {{.RepoName}}";
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

        programs.lazygit = {
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
