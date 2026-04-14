{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."snacks-terminal" ];
  dots.nixvim._."snacks-terminal".homeManager = { ... }: {
  programs.nixvim = {
    plugins.snacks.settings.terminal = {
      enabled = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options = {
          desc = "Toggle Terminal";
        };
      }
      {
        mode = "t";
        key = "<C-\\>";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options = {
          desc = "Toggle Terminal";
        };
      }
    ];
  };
  };
}
