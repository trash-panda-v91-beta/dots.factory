{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."snacks-rename" ];
  dots.nixvim._."snacks-rename".homeManager = { ... }: {
  programs.nixvim = {
    plugins.snacks.settings.rename.enabled = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>fR";
        action = "<cmd>lua Snacks.rename.rename_file()<CR>";
        options.desc = "Rename File";
      }
    ];
  };
  };
}
