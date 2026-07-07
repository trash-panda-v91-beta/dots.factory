{ inputs, ... }:
{
  dots.tool._.hunk = {
    description = "hunk - review-first terminal diff viewer for agent changesets";

    includes = [ { homeManager.imports = [ inputs.hunk.homeManagerModules.default ]; } ];

    homeManager =
      { pkgs, ... }:
      {
        programs.hunk = {
          enable = true;
          package = inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
          enableGitIntegration = true;
          settings = {
            theme = "auto";
            mode = "auto";
            line_numbers = true;
          };
        };
      };
  };
}
