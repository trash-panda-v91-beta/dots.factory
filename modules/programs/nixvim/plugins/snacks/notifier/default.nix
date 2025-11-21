{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.notifier";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim = {
      plugins.snacks.settings.notifier = {
        enabled = true;
        style = "fancy"; # "compact" | "fancy" | "minimal"
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>un";
          action = "<cmd>lua Snacks.notifier.hide()<CR>";
          options.desc = "Dismiss All Notifications";
        }
        {
          mode = "n";
          key = "<leader>uN";
          action = "<cmd>lua Snacks.notifier.show_history()<CR>";
          options.desc = "Show Notification History";
        }
      ];
    };
  };
}
