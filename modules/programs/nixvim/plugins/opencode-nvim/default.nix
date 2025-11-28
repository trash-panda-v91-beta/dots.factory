{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.opencode-nvim";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    extraPlugins = [ pkgs.local.opencode-nvim ];

    plugins.blink-cmp.settings = {
      completion.menu.draw.components.kind = {
        text.__raw = ''
          function(ctx)
            if ctx.item and ctx.item.source_id == "opencode_mentions" then
              return "Mentions"
            end
            return ctx.kind
          end
        '';
      };

      sources = {
        default = lib.mkAfter [ "opencode_mentions" ];
        providers.opencode_mentions = {
          enabled = true;
          async = true;
          module = "opencode.ui.completion.engines.blink_cmp";
          name = "Opencode";
          transform_items.__raw = ''
            function(_, items)
              for _, item in ipairs(items) do
                item.kind = require('blink.cmp.types').CompletionItemKind.Reference
              end
              return items
            end
          '';
        };
      };
    };

    extraConfigLua = ''
      require("opencode").setup({
      	preferred_picker = "snacks.picker",
      	preferred_completion = "blink",
      	keymap = {
      		editor = {
      			["<A-o>"] = { "toggle", mode = { "n", "i" } },
      		},
      	},
      	ui = {
      		window_width = 0.95,
      		zoom_width = 0.95,
      	},
      })
    '';
  };
}
