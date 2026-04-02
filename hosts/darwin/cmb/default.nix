{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "cmb";

  features = [
    "aws"
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
      ai.mcp.servers = {
        perplexity = {
          autoApprove = [ ];
          disabled = false;
          timeout = 60;
          type = "sse";
          url = inputs.vault.constants.services.mcp.perplexity.corporate;
        };
      };
      programs = {
        bun.enable = false;
        obsidian = {
          enable = true;
          vaults.nil.target = "SAPDevelop/vaults/nil";
          vaults.mist = {
            target = "SAPDevelop/vaults/mist";
            extraCorePlugins = [
              {
                name = "sync";
                settings = {
                  deviceName = "cmb";
                  syncPluginSettings = true;
                };
              }
            ];
          };
        };
        colima.enable = true;
        git.userEmail = myconfig.user.email;
        jira-cli = {
          enable = true;
          tokenReference = "op://Private/Jira token/password";
        };
        nixvim.plugins.obsidian = {
          enable = true;
          workspaces = [
            {
              name = "nil";
              path = "~/SAPDevelop/vaults/nil";
            }
            {
              name = "mist";
              path = "~/SAPDevelop/vaults/mist";
            }
          ];
        };
        nixvim.plugins.obsidian-bases-nvim = {
          enable = true;
          vaults = [
            {
              name = "nil";
              path = "SAPDevelop/vaults/nil";
            }
            {
              name = "mist";
              path = "SAPDevelop/vaults/mist";
            }
          ];
        };
        nixvim.plugins.neogit.gitService = inputs.vault.constants.services.git.corporate;
        nixvim.plugins.octo.defaultToProjectsV2 = false;
        nixvim.plugins.octo.extraKeymaps = [
          {
            mode = "n";
            key = "<localleader>lr";
            action.__raw = ''
              function()
                vim.cmd('Octo label add approval/robocat')
                vim.defer_fn(function()
                  vim.cmd('Octo pr reload')
                end, 400)
              end
            '';
            desc = "PR Add approval/robocat";
          }
        ];
        nushell.enable = true;
        sesh.sessions = [
          {
            name = "nil";
            path = "~/SAPDevelop/vaults/nil";
            startup_command = "nvim";
          }
          {
            name = "mist";
            path = "~/SAPDevelop/vaults/mist";
            startup_command = "nvim";
          }
        ];
        opencode.env = {
          JIRA_URL = "{env:JIRA_URL}";
          JIRA_TOKEN = "{env:JIRA_TOKEN}";
        };
        opencode.providerSettings = {
          anthropic.options.baseURL = "http://localhost:6655/anthropic/v1";
          openai.options.baseURL = "http://localhost:6655/openai/v1";
          google.options.baseURL = "http://localhost:6655/gemini";
        };
        claude-code.env = {
          ANTHROPIC_MODEL = "anthropic--claude-sonnet-latest";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "anthropic--claude-sonnet-latest";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "anthropic--claude-haiku-latest";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "anthropic--claude-opus-latest";
        };
      };
    };
}
