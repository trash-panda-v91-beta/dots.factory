# Browse bundle - browser capability
{ __findFile, ... }:
{
  dots.bundle._.browse = {
    description = "Browsing capability (Zen Browser + future companions)";
    includes = [ <dots/tool/zen-browser> ];
  };
}
