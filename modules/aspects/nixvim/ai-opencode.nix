{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."ai-opencode" ];
  dots.nixvim._."ai-opencode".homeManager =
    { pkgs, lib, ... }:
    let
      settings = {
        preferred_picker = "snacks";
        ui = {
          position = "current";
        };
      };
    in
    {
      programs.nixvim = {
        extraPackages = [
          pkgs.opencode
        ];
        extraPlugins = [
          pkgs.local.opencode-nvim
          pkgs.vimPlugins.plenary-nvim
        ];

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

          -- Override Ctrl-S in neogit status buffer to use opencode toggle
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "NeogitStatus",
            callback = function()
              vim.keymap.set('n', '<C-s>', function()
                _G._opencode_toggle()
              end, { buffer = true, desc = "Toggle OpenCode" })
            end,
          })
        '';
      };
    };
}
