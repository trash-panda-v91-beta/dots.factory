{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.files ];
  dots.tool._.nixvim._.files.homeManager =
    { ... }:
    {
      programs.nixvim.plugins.mini = {
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

      programs.nixvim.keymaps = [
        {
          mode = "n";
          key = "-";
          action.__raw = ''
            function()
              local bufname = vim.api.nvim_buf_get_name(0)
              if bufname ~= "" and vim.bo.buftype == "" then
                MiniFiles.open(bufname)
              else
                MiniFiles.open()
              end
            end
          '';
          options = {
            desc = "Open file explorer (current file)";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "_";
          action.__raw = "function() MiniFiles.open(vim.loop.cwd()) end";
          options = {
            desc = "Open file explorer (cwd)";
            silent = true;
          };
        }
      ];
    };
}
