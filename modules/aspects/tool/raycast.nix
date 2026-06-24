{ den, ... }:
{
  dots.tool._.raycast = {
    description = "Raycast launcher";
    includes = [ (den._.unfree [ "raycast" ]) ];
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.raycast ];
      };
  };
}
