{ dots, ... }:
{
  dots.git.includes = [ dots.git._."snacks-lazygit" ];
  dots.git._."snacks-lazygit".homeManager = { ... }: {
  programs.nixvim = {
    plugins.snacks.settings.lazygit.enabled = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>lua Snacks.lazygit()<CR>";
        options.desc = "Open lazygit";
      }
    ];
  };
  };
}
