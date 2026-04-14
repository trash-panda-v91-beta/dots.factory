{ lib, ... }:
{
  dots.runtimes =
    { user, ... }:
    {
      description = "Language runtimes: uv (Python), bun (JS), cargo (Rust), awscli";

      homeManager = {
        programs.uv.enable = true;
        programs.bun = {
          enable = lib.mkDefault true;
          enableGitIntegration = true;
        };
        programs.cargo.enable = true;
        programs.awscli.enable = true;
      };
    };
}
