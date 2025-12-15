{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "cmb";

  features = [
    "coding"
    "githubCopilot"
    "python"
  ];
  rice = "cyberdream-dark";
  type = "desktop";

  homeManagerUser = inputs.vault.constants.profiles.corporate;

  myconfig =
    {
      myconfig,
      ...
    }:
    {
      user.name = inputs.vault.constants.profiles.corporate;
      programs = {
        bun.enable = true;
        colima.enable = true;
        git.userEmail = myconfig.user.email;
        mcp.servers = {
          perplexity = {
            autoApprove = [ ];
            disabled = false;
            timeout = 60;
            type = "sse";
            url = inputs.vault.constants.services.mcp.perplexity.corporate;
          };
          jira = {
            disabled = false;
            command = "bunx";
            args = [
              "-y"
              "--registry=${inputs.vault.constants.services.artifactory.corporate.url}/api/npm/npm-sandbox-local"
              "${inputs.vault.constants.services.artifactory.corporate.namespace.putta}/server-jira"
            ];
            env = {
              JIRA_URL = "{env:JIRA_URL}";
              JIRA_TOKEN = "{env:JIRA_TOKEN}";
            };
          };
        };
        nixvim.plugins.obsidian = {
          enable = true;
          workspaces = [
            {
              name = "notes";
              path = "~/notes";
            }
          ];
        };
        nixvim.plugins.neogit.gitService = inputs.vault.constants.services.git.corporate;
        nushell.enable = true;
        opencode.env = {
          JIRA_URL = "{env:JIRA_URL}";
          JIRA_TOKEN = "{env:JIRA_TOKEN}";
        };
      };
    };
}
