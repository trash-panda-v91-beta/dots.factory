{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.keymaps-code";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {

    # Global code keymaps with filetype-aware dispatch
    keymaps = [
      # Run code at cursor
      {
        mode = "n";
        key = "<leader>cr";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('run')
            else
              vim.notify('No runner configured for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Run code";
      }

      # Run with picker
      {
        mode = "n";
        key = "<leader>cR";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('runnables')
            else
              vim.notify('Picker not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Run (picker)";
      }

      # Re-run last runnable
      {
        mode = "n";
        key = "<leader>cl";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp({ 'runnables', bang = true })
            else
              vim.notify('Re-run not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Run last";
      }

      # Test at cursor
      {
        mode = "n";
        key = "<leader>ct";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('testables')
            else
              vim.notify('Test runner not configured for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Test";
      }

      # Test with picker (capital T)
      {
        mode = "n";
        key = "<leader>cT";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp({ 'testables', bang = true })
            else
              vim.notify('Test picker not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Test last";
      }

      # Debug at cursor
      {
        mode = "n";
        key = "<leader>cd";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('debug')
            else
              vim.notify('Debugger not configured for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Debug";
      }

      # Debug with picker
      {
        mode = "n";
        key = "<leader>cD";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('debuggables')
            else
              vim.notify('Debug picker not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Debug (picker)";
      }

      # Explain error (has fallback to diagnostic float)
      {
        mode = "n";
        key = "<leader>ce";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('explainError')
            else
              vim.diagnostic.open_float()
            end
          end
        '';
        options.desc = "Explain error";
      }

      # Expand macro (Rust-specific)
      {
        mode = "n";
        key = "<leader>cE";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('expandMacro')
            else
              vim.notify('Macro expansion not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Expand macro";
      }

      # Code action (using fastaction)
      {
        mode = "n";
        key = "<leader>ca";
        action.__raw = ''
          function()
            require('fastaction').code_action()
          end
        '';
        options.desc = "Code action";
      }

      # Visual mode code action (using fastaction)
      {
        mode = "v";
        key = "<leader>ca";
        action.__raw = ''
          function()
            require('fastaction').range_code_action()
          end
        '';
        options.desc = "Code action (range)";
      }

      # Hover actions (has fallback to generic LSP hover)
      {
        mode = "n";
        key = "<leader>ch";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp({ 'hover', 'actions' })
            else
              vim.lsp.buf.hover()
            end
          end
        '';
        options.desc = "Hover actions";
      }

      # Open config file (Cargo.toml for Rust)
      {
        mode = "n";
        key = "<leader>cC";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('openCargo')
            else
              vim.notify('Config file opener not configured for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Open config";
      }

      # Parent module (Rust-specific)
      {
        mode = "n";
        key = "<leader>cp";
        action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == 'rust' then
              vim.cmd.RustLsp('parentModule')
            else
              vim.notify('Parent module navigation not available for ' .. ft, vim.log.levels.WARN)
            end
          end
        '';
        options.desc = "Parent module";
      }
    ];

    # FileType-specific autocommands for buffer-local customizations
    autoCmd = [
      # Rust: Override K for hover actions + add which-key group
      {
        event = [ "FileType" ];
        pattern = [ "rust" ];
        callback.__raw = ''
          function(event)
            -- Override K to show hover actions instead of standard hover
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp({ 'hover', 'actions' })
            end, { 
              buffer = event.buf, 
              desc = "Rust hover actions",
              silent = true 
            })
            
            -- Add which-key group with Rust icon
            require('which-key').add({
              { '<leader>c', group = 'Code (Rust)', buffer = event.buf, icon = '🦀' }
            })
          end
        '';
      }

      # Generic fallback for other languages
      {
        event = [ "FileType" ];
        pattern = [
          "python"
          "go"
          "javascript"
          "typescript"
          "lua"
          "nix"
        ];
        callback.__raw = ''
          function(event)
            local ft = vim.bo[event.buf].filetype
            local icons = {
              python = '🐍',
              go = '🔷',
              javascript = '📜',
              typescript = '📘',
              lua = '🌙',
              nix = '❄️',
            }
            require('which-key').add({
              { '<leader>c', group = 'Code (' .. ft .. ')', buffer = event.buf, icon = icons[ft] or '💻' }
            })
          end
        '';
      }
    ];
  };
}
