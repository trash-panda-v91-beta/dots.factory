{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.jira-cli";

  options.programs.jira-cli = {
    enable = delib.boolOption false;
    alias = delib.strOption "jira";
    tokenReference = delib.strOption "";
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      jiraExe = lib.getExe pkgs.jira-cli-go;
      opExe = lib.getExe pkgs._1password-cli;

      jiraFunction =
        if cfg.tokenReference == "" then
          ''
            def --wrapped ${cfg.alias} [...args] {
              ^${jiraExe} ...$args
            }
          ''
        else
          ''
            def --wrapped ${cfg.alias} [...args] {
              with-env { JIRA_API_TOKEN: '${cfg.tokenReference}' } {
                ^${opExe} run -- ${jiraExe} ...$args
              }
            }
          '';
    in
    {
      home.packages = [ pkgs.jira-cli-go ];

      programs.nushell.extraConfig = jiraFunction;
    };
}
