{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.gh-dash";

  options.programs.gh-dash = with delib; {
    enable = boolOption host.codingFeatured;
    settings = attrsOption { };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.gh-dash = {
        enable = cfg.enable;
        settings = delib.lib.recursiveUpdate
          {
            prSections = [
              {
                title = "My Pull Requests";
                filters = "is:open author:@me";
              }
              {
                title = "Needs My Review";
                filters = "is:open review-requested:@me";
              }
              {
                title = "Involved";
                filters = "is:open involves:@me -author:@me";
              }
            ];
            issuesSections = [
              {
                title = "My Issues";
                filters = "is:open author:@me";
              }
              {
                title = "Assigned";
                filters = "is:open assignee:@me";
              }
            ];
            defaults = {
              preview = {
                open = true;
                width = 50;
              };
              prsLimit = 20;
              issuesLimit = 20;
            };
          }
          cfg.settings;
      };
    };
}
