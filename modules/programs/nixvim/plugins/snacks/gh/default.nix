{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.gh";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    extraPackages = [
      pkgs.gh
    ];
    plugins.snacks.settings.gh = {
      enable = true;
    };
    plugins.snacks.settings.picker = {
      sources = {
        gh_issue = {
          preview = false;
        };
        gh_pr = {
          preview = false;
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>gi";
        action.__raw = "function() Snacks.picker.gh_issue() end";
        options = {
          desc = "GitHub Issues (open)";
        };
      }
      {
        mode = "n";
        key = "<leader>gI";
        action.__raw = "function() Snacks.picker.gh_issue({ state = 'all' }) end";
        options = {
          desc = "GitHub Issues (all)";
        };
      }
      {
        mode = "n";
        key = "<leader>gp";
        action.__raw = "function() Snacks.picker.gh_pr() end";
        options = {
          desc = "GitHub Pull Requests (open)";
        };
      }
      {
        mode = "n";
        key = "<leader>gP";
        action.__raw = "function() Snacks.picker.gh_pr({ state = 'all' }) end";
        options = {
          desc = "GitHub Pull Requests (all)";
        };
      }
    ];
  };
}
