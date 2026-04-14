{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."snacks-bufdelete" ];
  dots.nixvim._."snacks-bufdelete".homeManager = { ... }: {
  programs.nixvim = {
    plugins.snacks.settings.bufdelete.enabled = true;

    keymaps = [
      {
        mode = "n";
        key = "<C-w>";
        action = "<cmd>lua Snacks.bufdelete.delete()<cr>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>lua Snacks.bufdelete.delete()<cr>";
        options.desc = "Delete buffer";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>e #<cr>";
        options.desc = "Switch to last buffer";
      }
      {
        mode = "n";
        key = "<leader>bc";
        action = "<cmd>lua Snacks.bufdelete.other()<cr>";
        options.desc = "Close all buffers but current";
      }
      {
        mode = "n";
        key = "<leader>bC";
        action = "<cmd>lua Snacks.bufdelete.all()<cr>";
        options.desc = "Close all buffers";
      }
    ];
  };
  };
}
