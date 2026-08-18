{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.picker ];
  dots.tool._.nixvim._.picker.homeManager =
    { pkgs, ... }:
    {
      programs.nixvim = {
        extraPackages = [ pkgs.ripgrep ];

        plugins.mini-pick = {
          enable = true;
          settings.options.use_cache = true;
        };

        plugins.mini-extra.enable = true;

        # Wire vim.ui.select through mini.pick so plugins that call it (incl. octo)
        # get the same picker UX.
        extraConfigLua = ''
          vim.ui.select = MiniPick.ui_select
        '';

        keymaps = [
          # Files / buffers / grep
          { mode = "n"; key = "<leader><space>"; action = "<cmd>Pick files<cr>"; options.desc = "Files"; }
          { mode = "n"; key = "<leader>ff"; action = "<cmd>Pick files<cr>"; options.desc = "Find files"; }
          { mode = "n"; key = "<leader>fF"; action.__raw = ''function() MiniPick.builtin.files({ tool = 'rg', source = { name = 'Files (all)' } }, { source = { cwd = vim.fn.getcwd() } }) end''; options.desc = "Find files (all)"; }
          { mode = "n"; key = "<leader>fb"; action = "<cmd>Pick buffers<cr>"; options.desc = "Buffers"; }
          { mode = "n"; key = "<leader>fw"; action = "<cmd>Pick grep_live<cr>"; options.desc = "Live grep"; }
          { mode = [ "n" "x" ]; key = "<leader>f*"; action = "<cmd>Pick grep pattern='<cword>'<cr>"; options.desc = "Grep word"; }
          { mode = "n"; key = "<leader>fo"; action = "<cmd>Pick oldfiles<cr>"; options.desc = "Recent files"; }
          { mode = "n"; key = "<leader>fh"; action = "<cmd>Pick help<cr>"; options.desc = "Help tags"; }
          { mode = "n"; key = "<leader>f/"; action = "<cmd>Pick buf_lines scope='current'<cr>"; options.desc = "Fuzzy find in buffer"; }
          { mode = "n"; key = "<leader>f?"; action = "<cmd>Pick buf_lines scope='all'<cr>"; options.desc = "Fuzzy find in open buffers"; }
          { mode = "n"; key = "<leader>f<CR>"; action = "<cmd>Pick resume<cr>"; options.desc = "Resume find"; }
          { mode = "n"; key = "<leader>f'"; action = "<cmd>Pick marks<cr>"; options.desc = "Marks"; }
          { mode = "n"; key = "<leader>fr"; action = "<cmd>Pick registers<cr>"; options.desc = "Registers"; }
          { mode = "n"; key = "<leader>fk"; action = "<cmd>Pick keymaps<cr>"; options.desc = "Keymaps"; }
          { mode = "n"; key = "<leader>fc"; action = "<cmd>Pick commands<cr>"; options.desc = "Commands"; }
          { mode = "n"; key = "<leader>:"; action = "<cmd>Pick history scope='cmd'<cr>"; options.desc = "Command history"; }
          { mode = "n"; key = "<leader>fS"; action = "<cmd>Pick spellsuggest<cr>"; options.desc = "Spelling suggestions"; }
          { mode = "n"; key = "<leader>fq"; action = "<cmd>Pick list scope='quickfix'<cr>"; options.desc = "Quickfix"; }
          { mode = "n"; key = "<leader>fC"; action.__raw = ''function() MiniPick.builtin.files(nil, { source = { cwd = vim.fn.stdpath('config') } }) end''; options.desc = "Config files"; }

          # File explorer (mini.files - already enabled in files.nix)
          { mode = "n"; key = "<leader>fe"; action = "<cmd>lua MiniFiles.open()<cr>"; options.desc = "File explorer"; }

          # Diagnostics
          { mode = "n"; key = "<leader>fd"; action = "<cmd>Pick diagnostic scope='current'<cr>"; options.desc = "Buffer diagnostics"; }
          { mode = "n"; key = "<leader>fD"; action = "<cmd>Pick diagnostic scope='all'<cr>"; options.desc = "Workspace diagnostics"; }

          # LSP
          { mode = "n"; key = "<leader>fs"; action = "<cmd>Pick lsp scope='document_symbol'<cr>"; options.desc = "Document symbols"; }
          { mode = "n"; key = "<leader>ld"; action = "<cmd>Pick lsp scope='definition'<cr>"; options.desc = "Goto Definition"; }
          { mode = "n"; key = "<leader>li"; action = "<cmd>Pick lsp scope='implementation'<cr>"; options.desc = "Goto Implementation"; }
          { mode = "n"; key = "<leader>lD"; action = "<cmd>Pick lsp scope='references'<cr>"; options.desc = "References"; }
          { mode = "n"; key = "<leader>lt"; action = "<cmd>Pick lsp scope='type_definition'<cr>"; options.desc = "Goto Type Definition"; }
          { mode = "n"; key = "gd"; action = "<cmd>Pick lsp scope='definition'<cr>"; options.desc = "Goto Definition"; }
          { mode = "n"; key = "gD"; action = "<cmd>Pick lsp scope='declaration'<cr>"; options.desc = "Goto Declaration"; }
          { mode = "n"; key = "gR"; action = "<cmd>Pick lsp scope='references'<cr>"; options.desc = "References"; }
          { mode = "n"; key = "gI"; action = "<cmd>Pick lsp scope='implementation'<cr>"; options.desc = "Goto Implementation"; }
          { mode = "n"; key = "gy"; action = "<cmd>Pick lsp scope='type_definition'<cr>"; options.desc = "Goto Type Definition"; }

          # Git
          { mode = "n"; key = "<leader>fG"; action = "<cmd>Pick git_files<cr>"; options.desc = "Git files"; }
          { mode = "n"; key = "<leader>gb"; action = "<cmd>Pick git_branches<cr>"; options.desc = "Git branches"; }
          { mode = "n"; key = "<leader>gC"; action = "<cmd>Pick git_commits<cr>"; options.desc = "Git commits"; }
          { mode = "n"; key = "<leader>gL"; action = "<cmd>Pick git_commits path='%'<cr>"; options.desc = "Git commits (file)"; }
          { mode = "n"; key = "<leader>gf"; action = "<cmd>Pick git_hunks<cr>"; options.desc = "Git hunks"; }

          # Rename file via mini.files
          { mode = "n"; key = "<leader>fR"; action.__raw = ''
            function()
              local old = vim.api.nvim_buf_get_name(0)
              vim.ui.input({ prompt = 'Rename to: ', default = old, completion = 'file' }, function(new)
                if not new or new == "" or new == old then return end
                vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
                local ok, err = pcall(vim.fn.rename, old, new)
                if not ok then vim.notify('Rename failed: ' .. err, vim.log.levels.ERROR); return end
                vim.cmd.edit(vim.fn.fnameescape(new))
                vim.cmd.bdelete(vim.fn.bufnr(old))
              end)
            end
          ''; options.desc = "Rename file"; }
        ];
      };
    };
}
