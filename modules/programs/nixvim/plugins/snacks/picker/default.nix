{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.picker";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {

    extraPackages = [
      pkgs.ripgrep
    ];
    plugins.snacks.settings.picker = {
      enabled = true;
      ui_select = true;
      prompt = "";

      formatters = {
        file = {
          filename_first = true;
          truncate = 100;
        };
      };

      layout = "vertical";

      layouts = {
        select = {
          layout = {
            relative = "cursor";
            width = 70;
            min_width = 0;
            row = 1;
          };
        };
      };

      win = {
        list = {
          on_buf.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
        };
        preview = {
          on_buf.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
          on_close.__raw = ''
            function(self)
                self:execute 'calculate_file_truncate_width'
            end
          '';
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader><space>";
        action = ''<cmd>lua Snacks.picker.smart()<cr>'';
        options = {
          desc = "Smart Files";
        };
      }
      {
        mode = "n";
        key = "<leader>:";
        action = ''<cmd>lua Snacks.picker.command_history()<cr>'';
        options = {
          desc = "Command History";
        };
      }

      {
        mode = "n";
        key = "<leader>fa";
        action = ''<cmd>lua Snacks.picker.autocmds()<cr>'';
        options = {
          desc = "Find autocmds";
        };
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = ''<cmd>lua Snacks.picker.buffers()<cr>'';
        options = {
          desc = "Find buffers";
        };
      }
      {
        mode = "n";
        key = "<leader>fc";
        action = ''<cmd>lua Snacks.picker.commands()<cr>'';
        options = {
          desc = "Find commands";
        };
      }
      {
        mode = "n";
        key = "<leader>fC";
        action.__raw = ''
          function()
            require("snacks.picker").files {
              prompt_title = "Config Files",
              cwd = vim.fn.stdpath("config"),
            }
          end
        '';
        options = {
          desc = "Find config files";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>fe";
        action = ''<cmd>lua Snacks.explorer()<cr>'';
        options = {
          desc = "File Explorer";
        };
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = ''<cmd>lua Snacks.picker.files()<cr>'';
        options = {
          desc = "Find files";
        };
      }
      {
        mode = "n";
        key = "<leader>fF";
        action = ''<cmd>lua Snacks.picker.files({hidden = true, ignored = true})<cr>'';
        options = {
          desc = "Find files (All files)";
        };
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = ''<cmd>lua Snacks.picker.help()<cr>'';
        options = {
          desc = "Find help tags";
        };
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = ''<cmd>lua Snacks.picker.keymaps()<cr>'';
        options = {
          desc = "Find keymaps";
        };
      }
      {
        mode = "n";
        key = "<leader>fm";
        action = ''<cmd>lua Snacks.picker.man()<cr>'';
        options = {
          desc = "Find man pages";
        };
      }
      {
        mode = "n";
        key = "<leader>fo";
        action = ''<cmd>lua Snacks.picker.recent()<cr>'';
        options = {
          desc = "Find old files";
        };
      }
      {
        mode = "n";
        key = "<leader>fO";
        action = ''<cmd>lua Snacks.picker.smart()<cr>'';
        options = {
          desc = "Find Smart (Frecency)";
        };
      }
      {
        mode = "n";
        key = "<leader>fp";
        action = ''<cmd>lua Snacks.picker.projects()<cr>'';
        options = {
          desc = "Find projects";
        };
      }
      {
        mode = "n";
        key = "<leader>fq";
        action = ''<cmd>lua Snacks.picker.qflist()<cr>'';
        options = {
          desc = "Find quickfix";
        };
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = ''<cmd>lua Snacks.picker.registers()<cr>'';
        options = {
          desc = "Find registers";
        };
      }
      {
        mode = "n";
        key = "<leader>fS";
        action = ''<CMD>lua Snacks.picker.spelling({layout = { preset = "select" }})<CR>'';
        options = {
          desc = "Find spelling suggestions";
        };
      }
      {
        mode = "n";
        key = "<leader>fu";
        action = "<cmd>lua Snacks.picker.undo()<cr>";
        options = {
          desc = "Undo History";
        };
      }
      {
        mode = "n";
        key = "<leader>fw";
        action = "<cmd>lua Snacks.picker.grep()<cr>";
        options = {
          desc = "Live grep";
        };
      }
      {
        mode = "n";
        key = "<leader>fW";
        action = "<cmd>lua Snacks.picker.grep({hidden = true, ignored = true})<cr>";
        options = {
          desc = "Live grep (All files)";
        };
      }
      {
        mode = "n";
        key = "<leader>f,";
        action = ''<cmd>lua Snacks.picker.icons({layout = { preset = "select" }})<cr>'';
        options = {
          desc = "Find icons";
        };
      }
      {
        mode = "n";
        key = "<leader>f'";
        action = ''<cmd>lua Snacks.picker.marks()<cr>'';
        options = {
          desc = "Find marks";
        };
      }
      {
        mode = "n";
        key = "<leader>f/";
        action = ''<cmd>lua Snacks.picker.lines()<cr>'';
        options = {
          desc = "Fuzzy find in current buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>f?";
        action = ''<cmd>lua Snacks.picker.grep_buffers()<cr>'';
        options = {
          desc = "Fuzzy find in open buffers";
        };
      }
      {
        mode = "n";
        key = "<leader>f<CR>";
        action = ''<cmd>lua Snacks.picker.resume()<cr>'';
        options = {
          desc = "Resume find";
        };
      }

      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>sw";
        action = ''<cmd>lua Snacks.picker.grep_word()<cr>'';
        options = {
          desc = "Search Word (visual or cursor)";
        };
      }
      {
        mode = "n";
        key = "<leader>fG";
        action = ''<cmd>lua Snacks.picker.git_files()<cr>'';
        options = {
          desc = "Find Git Files";
        };
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = ''<cmd>lua Snacks.picker.git_branches()<cr>'';
        options = {
          desc = "Find git branches";
        };
      }
      {
        mode = "n";
        key = "<leader>gC";
        action = ''<cmd>lua Snacks.picker.git_log()<cr>'';
        options = {
          desc = "Find git commits";
        };
      }
      {
        mode = "n";
        key = "<leader>gL";
        action = ''<cmd>lua Snacks.picker.git_log_line()<cr>'';
        options = {
          desc = "Git Log Line";
        };
      }
      {
        mode = "n";
        key = "<leader>gD";
        action = ''<cmd>lua Snacks.picker.git_diff()<cr>'';
        options = {
          desc = "Git Diff (Hunks)";
        };
      }
      {
        mode = "n";
        key = "<leader>gf";
        action = ''<cmd>lua Snacks.picker.git_log_file()<cr>'';
        options = {
          desc = "Git Log File";
        };
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = ''<cmd>lua Snacks.picker.diagnostics_buffer()<cr>'';
        options = {
          desc = "Find buffer diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>fD";
        action = ''<cmd>lua Snacks.picker.diagnostics()<cr>'';
        options = {
          desc = "Find workspace diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = ''<cmd>lua Snacks.picker.lsp_symbols()<cr>'';
        options = {
          desc = "Find lsp document symbols";
        };
      }

      {
        mode = "n";
        key = "<leader>ca";
        action = ''<cmd>lua Snacks.picker.lsp_code_actions()<cr>'';
        options = {
          desc = "Code Action";
        };
      }
      {
        mode = "n";
        key = "<leader>ld";
        action = ''<cmd>lua Snacks.picker.lsp_definitions()<cr>'';
        options = {
          desc = "Goto Definition";
        };
      }
      {
        mode = "n";
        key = "<leader>li";
        action = ''<cmd>lua Snacks.picker.lsp_implementations()<cr>'';
        options = {
          desc = "Goto Implementation";
        };
      }
      {
        mode = "n";
        key = "<leader>lD";
        action = ''<cmd>lua Snacks.picker.lsp_references()<cr>'';
        options = {
          desc = "Find references";
        };
      }
      {
        mode = "n";
        key = "<leader>lt";
        action = ''<cmd>lua Snacks.picker.lsp_type_definitions()<cr>'';
        options = {
          desc = "Goto Type Definition";
        };
      }

      {
        mode = "n";
        key = "gd";
        action = ''<cmd>lua Snacks.picker.lsp_definitions()<cr>'';
        options = {
          desc = "Goto Definition";
        };
      }
      {
        mode = "n";
        key = "gD";
        action = ''<cmd>lua Snacks.picker.lsp_declarations()<cr>'';
        options = {
          desc = "Goto Declaration";
        };
      }
      {
        mode = "n";
        key = "gR";
        action = ''<cmd>lua Snacks.picker.lsp_references()<cr>'';
        options = {
          desc = "References";
          nowait = true;
        };
      }
      {
        mode = "n";
        key = "gI";
        action = ''<cmd>lua Snacks.picker.lsp_implementations()<cr>'';
        options = {
          desc = "Goto Implementation";
        };
      }
      {
        mode = "n";
        key = "gy";
        action = ''<cmd>lua Snacks.picker.lsp_type_definitions()<cr>'';
        options = {
          desc = "Goto T[y]pe Definition";
        };
      }
    ];
  };
}
