{
  delib,
  pkgs,
  lib,
  host,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.opencode-nvim";

  options.programs.nixvim.plugins.opencode-nvim = with delib; {
    enable = boolOption host.codingFeatured;
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for opencode.nvim plugin";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      # Merge user settings with defaults
      settings = lib.recursiveUpdate {
        preferred_picker = "snacks";
        preferred_completion = "blink";
        ui = {
          position = "current";
        };
      } cfg.settings;
    in
    {
      programs.nixvim = {
        extraPackages = [
          pkgs.local.opencode
        ];
        extraPlugins = [
          pkgs.local.opencode-nvim
          pkgs.vimPlugins.plenary-nvim
        ];

        # Configure blink-cmp for opencode
        # Note: Do NOT register opencode_mentions provider here - opencode.nvim does it via add_source_provider
        # We only configure the kind display
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
        };

        # Quick toggle keymaps (Alt for context-switching per KEYMAP_STRATEGY.md)
        keymaps = [
          {
            mode = [
              "n"
              "i"
            ];
            key = "<C-s>";
            action.__raw = "function() _G._opencode_toggle() end";
            options.desc = "Toggle OpenCode";
          }
        ];

        extraConfigLua = ''
          -- Opencode setup with blink.cmp integration
          local opencode_setup_done = false
          local function setup_opencode()
            if opencode_setup_done then return end
            -- Force load blink.cmp via lz.n (it's lazy-loaded on InsertEnter)
            local lzn_ok, lzn = pcall(require, 'lz.n')
            if lzn_ok and lzn.trigger_load then
              lzn.trigger_load('blink.cmp')
            end
            opencode_setup_done = true
            require("opencode").setup(${lib.generators.toLua { multiline = true; } settings})
          end

          -- Expose setup function globally for keymaps to use
          _G._opencode_toggle = function()
            setup_opencode()
            require('opencode.api').toggle()
          end

          -- Also setup on InsertEnter for users who don't use the keymap
          vim.api.nvim_create_autocmd("InsertEnter", {
            callback = function()
              vim.schedule(setup_opencode)
            end,
            once = true,
          })
        '';
      };
    };
}
