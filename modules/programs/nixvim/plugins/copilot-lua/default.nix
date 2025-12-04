{
  delib,
  host,
  lib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.copilot-lua";

  options = delib.singleEnableOption host.githubCopilotFeatured;

  home.ifEnabled.programs.nixvim = {
    plugins = {
      blink-copilot.enable = true;

      blink-cmp.settings.sources = {
        default = lib.mkAfter [ "copilot" ];

        providers.copilot = {
          enabled.__raw = ''
            function()
              if vim.g.copilot_completions_enabled == nil then
                vim.g.copilot_completions_enabled = true
              end
              return vim.g.copilot_completions_enabled
            end
          '';
          async = true;
          module = "blink-copilot";
          name = "copilot";
        };
      };

      copilot-lua = {
        lazyLoad.settings.event = [ "InsertEnter" ];
        enable = true;
        settings = {
          panel.enable = false;
          suggestions.enable = false;
        };
      };

      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>sg";
          group = "GitHub Copilot";
          icon = "";
          mode = [ "n" ];
        }
      ];
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>sgc";
        action.__raw = ''
          function()
            if vim.g.copilot_completions_enabled == nil then
              vim.g.copilot_completions_enabled = true
            end
            vim.g.copilot_completions_enabled = not vim.g.copilot_completions_enabled
            local status = vim.g.copilot_completions_enabled and "enabled" or "disabled"
            vim.notify(
              string.format("GitHub Copilot completions: %s", status),
              vim.log.levels.INFO
            )
          end
        '';
        options.desc = "Toggle GitHub Copilot Completions";
      }
    ];
  };
}
