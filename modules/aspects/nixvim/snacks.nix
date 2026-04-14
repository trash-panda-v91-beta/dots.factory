{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._.snacks ];
  dots.nixvim._.snacks.homeManager = { ... }: {
    programs.nixvim.plugins.snacks.enable = true;
  };
}
