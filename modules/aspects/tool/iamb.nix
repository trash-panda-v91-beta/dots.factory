{ ... }:
{
  dots.tool._.iamb = {
    description = "iamb - terminal Matrix client";

    homeManager = { pkgs, ... }: {
      programs.iamb = {
        enable = true;
        settings = {
          default_profile = "personal";
          profiles.personal.user_id = "@petr:nebular-grid.space";
        };
      };
    };
  };
}
