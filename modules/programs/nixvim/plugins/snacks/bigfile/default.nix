{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.bigfile";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim = {
      plugins.snacks.settings.bigfile = {
        enabled = true;
        size = 1024 * 1024; # 1MB

        setup.__raw = ''
          function(ctx)
            -- Disable line numbers and relative line numbers
            vim.cmd("setlocal nonumber norelativenumber")

            -- Syntax highlighting
            vim.schedule(function()
              vim.bo[ctx.buf].syntax = ctx.ft
            end)

            -- Disable matchparen
            vim.cmd("let g:loaded_matchparen = 1")
            if vim.fn.exists(":NoMatchParen") ~= 0 then
              vim.cmd([[NoMatchParen]])
            end

            -- Disable cursor line and column
            vim.cmd("setlocal nocursorline nocursorcolumn")

            -- Disable folding
            vim.cmd("setlocal nofoldenable")

            -- Disable sign column
            vim.cmd("setlocal signcolumn=no")

            -- Disable swap file and undo file
            vim.cmd("setlocal noswapfile noundofile")

            Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })

            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ctx.buf) then
                vim.bo[ctx.buf].syntax = ctx.ft
              end
            end)
          end
        '';
      };
    };
  };
}
