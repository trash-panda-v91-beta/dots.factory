{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._.nav ];
  dots.nixvim._.nav.homeManager = { ... }: {
    programs.nixvim = {
      plugins.tmux-navigator.enable = true;
      plugins.snacks.settings.scope = {
        enabled = true;
        treesitter.blocks.enabled = true;
      };
    };
  };
}
