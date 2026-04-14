{ lib, ... }:
{
  dots.git =
    { user, ... }:
    {
      description = "Git workflow: git, gh, lazygit, delta + gitsigns, neogit, diffview, octo, snacks/lazygit";

      homeManager =
        { pkgs, ... }:
        {
          programs.delta.enable = true;
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
                  title = "My Pull Requests";
                  filters = "is:open author:@me";
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
                  width = 50;
                };
                prsLimit = 20;
                issuesLimit = 20;
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
