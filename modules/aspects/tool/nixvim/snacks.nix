{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.snacks ];
  dots.tool._.nixvim._.snacks.homeManager = { ... }: {
    programs.nixvim.plugins.snacks.enable = true;
  };
}
