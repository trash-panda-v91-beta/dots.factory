{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._.files ];
  dots.nixvim._.files.homeManager = { lib, ... }:
let
  # Hardcode the provider since we're removing the option layer
  # Change this value to switch file managers: "mini-files", "oil", or "yazi"
  provider = "mini-files";

  isMiniFiles = provider == "mini-files";
  isOil = provider == "oil";
  isYazi = provider == "yazi";

  # Hardcoded keymaps (previously configurable via options)
  toggleKey = "<leader>e";
  toggleCurrentKey = "-";
  toggleCwdKey = "_";

  # Extract Lua functions for readability
  miniFilesOpenCurrent = ''
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" and vim.bo.buftype == "" then
      MiniFiles.open(bufname)
    else
      MiniFiles.open()
    end
  '';

  # Helper function to create keymaps
  mkKeymap = key: action: desc: {
    mode = "n";
    inherit key action;
    options = {
      inherit desc;
      silent = true;
    };
  };
in
{
  # Enable the selected file manager plugin
  programs.nixvim.plugins = {
    oil.enable = isOil;
    yazi.enable = isYazi;

    # mini.files requires special handling due to mini.nvim structure
    mini = lib.mkIf isMiniFiles {
      enable = true;
      modules.files = {
        mappings = {
          close = "<Esc>";
          go_in = "l";
          go_in_plus = "<CR>";
          synchronize = "s";
        };
      };
    };
  };

  # Configure unified keymaps based on the selected provider
  programs.nixvim.keymaps =
    if isMiniFiles then
      [
        {
          mode = "n";
          key = toggleKey;
          action.__raw = "function() MiniFiles.open() end";
          options = {
            desc = "Open file explorer";
            silent = true;
          };
        }
        {
          mode = "n";
          key = toggleCurrentKey;
          action.__raw = "function() ${miniFilesOpenCurrent} end";
          options = {
            desc = "Open file explorer in current folder";
            silent = true;
          };
        }
        {
          mode = "n";
          key = toggleCwdKey;
          action.__raw = "function() MiniFiles.open(vim.loop.cwd()) end";
          options = {
            desc = "Open file explorer in cwd";
            silent = true;
          };
        }
      ]
    else if isOil then
      [
        (mkKeymap toggleKey ":Oil<CR>" "Open file explorer")

        (mkKeymap toggleCurrentKey ":Oil .<CR>" "Open file explorer in current folder")

        {
          mode = "n";
          key = toggleCwdKey;
          action.__raw = "function() require('oil').open(vim.loop.cwd()) end";
          options = {
            desc = "Open file explorer in cwd";
            silent = true;
          };
        }
      ]
    else if isYazi then
      [
        (mkKeymap toggleKey ":Yazi<CR>" "Open file explorer")

        (mkKeymap toggleCurrentKey ":Yazi cwd<CR>" "Open file explorer in current folder")

        (mkKeymap toggleCwdKey ":Yazi<CR>" "Open file explorer in cwd")
      ]
    else
      [ ];
  };
}
