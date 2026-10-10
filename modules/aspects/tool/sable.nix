{ ... }:
{
  dots.tool._.sable = {
    description = "Sable Next (nightly) Matrix client macOS app, installed from the upstream release bundle";

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.local.sable ];
      };
  };
}
