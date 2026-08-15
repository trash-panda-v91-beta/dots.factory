{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._."testing-overseer" ];
  dots.tool._.nixvim._."testing-overseer".homeManager = { ... }: {
    programs.nixvim = {
      plugins.overseer = {
        enable = true;
        lazyLoad.settings.cmd = [
          "OverseerToggle"
          "OverseerRun"
          "OverseerRunCmd"
          "OverseerLoadBundle"
          "OverseerOpen"
          "OverseerClose"
          "OverseerInfo"
          "OverseerBuild"
          "OverseerQuickAction"
          "OverseerTaskAction"
        ];
        settings.templates = [ "builtin" ];
      };
      keymaps = [
        {
          mode = "n";
          key = "<leader>jj";
          action = "<cmd>OverseerToggle<cr>";
          options.desc = "Toggle Overseer";
        }
        {
          mode = "n";
          key = "<leader>jr";
          action = "<cmd>OverseerRun<cr>";
          options.desc = "Run task";
        }
        {
          mode = "n";
          key = "<leader>jc";
          action = "<cmd>OverseerRunCmd<cr>";
          options.desc = "Run command";
        }
        {
          mode = "n";
          key = "<leader>jl";
          action = "<cmd>OverseerLoadBundle<cr>";
          options.desc = "Load bundle";
        }
      ];
    };
  };
}
