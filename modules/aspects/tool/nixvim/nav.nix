{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.nav ];
  dots.tool._.nixvim._.nav.homeManager = { ... }: {
    programs.nixvim = {
      plugins.tmux-navigator.enable = true;
      plugins.snacks.settings.scope = {
        enabled = true;
        treesitter.blocks.enabled = true;
      };
    };
  };
}
