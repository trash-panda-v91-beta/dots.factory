{ delib, ... }:
let
  # Performance condition - disable for large files (>1MB)
  cond.__raw = ''
    function()
      local cache = {}
      return function()
        local bufnr = vim.api.nvim_get_current_buf()
        if cache[bufnr] == nil then
          local buf_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
          cache[bufnr] = buf_size < 1024 * 1024 -- 1MB limit
          -- Clear cache on buffer unload
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = bufnr,
            callback = function() cache[bufnr] = nil end,
          })
        end
        return cache[bufnr]
      end
    end
  '';
in
delib.module {
  name = "programs.nixvim.plugins.lualine";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.lualine = {
    enable = true;
    lazyLoad.settings.event = [
      "VimEnter"
      "BufReadPost"
      "BufNewFile"
    ];
    settings = {
      options = {
        disabled_filetypes = {
          __unkeyed-1 = "neo-tree";
          __unkeyed-2 = "trouble";
          __unkeyed-3 = "dashboard";
          __unkeyed-4 = "alpha";
          __unkeyed-5 = "ministarter";
          __unkeyed-6 = "oil";
          winbar = [
            "neo-tree"
            "trouble"
            "dashboard"
            "alpha"
            "oil"
          ];
        };
        globalstatus = true;
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };

      # +-------------------------------------------------+
      # | A | B | C                             X | Y | Z |
      # +-------------------------------------------------+
      sections = {
        lualine_a = [ "mode" ];

        lualine_b = [
          {
            __unkeyed-1 = "branch";
            icon = "";
          }
        ];

        lualine_c = [
          {
            __unkeyed-1 = "filename";
            symbols = {
              modified = "";
              readonly = "";
              unnamed = "[No Name]";
              newfile = "";
            };
            path = 1; # 0: just filename, 1: relative path, 2: absolute path, 3: absolute with tilde
          }
          {
            __unkeyed-1 = "diff";
            symbols = {
              added = " ";
              modified = " ";
              removed = " ";
            };
            colored = true;
            diff_color = {
              added = {
                fg = "#a6da95"; # Green
              };
              modified = {
                fg = "#eed49f"; # Yellow
              };
              removed = {
                fg = "#ed8796"; # Red
              };
            };
          }
        ];

        lualine_x = [
          # Diagnostics with custom colors and icons
          {
            __unkeyed-1 = "diagnostics";
            sources = [ "nvim_lsp" ];
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = " ";
            };
            diagnostics_color = {
              error = {
                fg = "#ed8796"; # Red
              };
              warn = {
                fg = "#eed49f"; # Yellow
              };
              info = {
                fg = "#8aadf4"; # Blue
              };
              hint = {
                fg = "#a6da95"; # Green
              };
            };
            colored = true;
          }

          # Show active LSP servers
          {
            __unkeyed-1.__raw = ''
              function()
                  local msg = ""
                  local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
                  local clients = vim.lsp.get_clients({ bufnr = 0 })
                  if next(clients) == nil then
                      return msg
                  end
                  
                  local client_names = {}
                  for _, client in ipairs(clients) do
                      local filetypes = client.config.filetypes
                      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                          table.insert(client_names, client.name)
                      end
                  end
                  
                  if #client_names > 0 then
                      return " " .. table.concat(client_names, ", ")
                  end
                  
                  return msg
              end
            '';
            icon = "";
            color = {
              fg = "#8aadf4"; # Blue
            };
          }

          "encoding"
          {
            __unkeyed-1 = "fileformat";
            symbols = {
              unix = "";
              dos = "";
              mac = "";
            };
          }
          "filetype"
        ];

        lualine_y = [
          "progress"
        ];

        lualine_z = [
          {
            __unkeyed-1 = "location";
            inherit cond;
          }
        ];
      };
    };
  };
}
