{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.render-markdown";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.render-markdown =
    let
      filetypes = [
        "codecompanion"
        "markdown"
        "opencode_output"
      ];
    in
    {
      enable = true;
      lazyLoad.settings.ft = filetypes;
      settings = {
        completions = {
          lsp = {
            enabled = true;
          };
        };
        file_types = filetypes;
        render_modes = true;
        link = {
          wiki = {
            body.__raw = ''
              function(ctx)
                -- Suppress icon for .base embeds — handled by obsidian-bases.nvim
                if ctx.destination and ctx.destination:match("%.base$") then
                  return ""
                end
                return nil
              end
            '';
          };
        };
        custom_handlers = { };
      };
    };
}
