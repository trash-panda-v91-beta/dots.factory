{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.ui ];
  dots.tool._.nixvim._.ui.homeManager =
    { ... }:
    {
      programs.nixvim.plugins.web-devicons.enable = true;
    };
}
