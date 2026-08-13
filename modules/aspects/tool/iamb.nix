{ ... }:
{
  dots.tool._.iamb = {
    description = "iamb - terminal Matrix client";

    homeManager = { ... }: {
      programs.iamb = {
        enable = true;
        settings = {
          default_profile = "personal";
          profiles.personal = {
            user_id = "@petr:nebular-grid.space";
            url = "https://matrix.nebular-grid.space";
          };
        };
      };
    };
  };
}
