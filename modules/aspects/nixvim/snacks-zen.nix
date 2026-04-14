{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."snacks-zen" ];
  dots.nixvim._."snacks-zen".homeManager = { ... }: {
  programs.nixvim = {
    plugins.snacks.settings.zen.enabled = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>bz";
        action = "<cmd>lua Snacks.zen.zoom()<cr>";
        options.desc = "Zoom buffer (toggle)";
      }
    ];
  };
  };
}
