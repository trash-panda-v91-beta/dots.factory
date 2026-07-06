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
          # enableGitIntegration stays off: delta already owns core.pager.
          # Use `hunk diff` / `hunk show` explicitly.
          settings = {
            theme = "auto";
            mode = "auto";
            line_numbers = true;
          };
        };
      };
  };
}
