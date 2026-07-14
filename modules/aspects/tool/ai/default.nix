{ den, lib, ... }:
let
  skillsDir = ./skills;
  skillFiles = builtins.attrNames (
    lib.filterAttrs (_: type: type == "regular") (builtins.readDir skillsDir)
  );
  skillNames = map (f: lib.removeSuffix ".md" f) skillFiles;
in
{
  dots.tool._.ai =
    { ... }:
    {
      description = "AI coding assistants";
      includes = [ (den._.unfree [ "claude-code" ]) ];

      homeManager =
        { config, pkgs, ... }:
        let
          piWebAccess = pkgs.local.pi-web-access;
          piMcpAdapter = pkgs.local.pi-mcp-adapter;
          context7Pi = pkgs.local.context7-pi;
          piLsp = pkgs.local.pi-lsp;
          ponytailPi = pkgs.local.ponytail-pi;
        in
        {
          home.sessionVariables.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
          home.sessionVariables.PI_SKIP_VERSION_CHECK = 1;
          programs.claude-code = {
            enable = true;
            enableMcpIntegration = true;
            settings = {
              alwaysThinkingEnabled = false;
              gitAttribution = false;
              includeCoAuthoredBy = false;
              theme = "dark";
            };
            skills = lib.genAttrs skillNames (name: skillsDir + "/${name}.md");
          };

          programs.pi-coding-agent = {
            enable = true;
            context = ./pi/AGENTS.md;
            settings = {
              theme = "dark";
              enableInstallTelemetry = false;
              enableAnalytics = false;
              defaultProvider = lib.mkDefault "anthropic";
              extensions = [
                "${piWebAccess}/index.js"
                "${context7Pi}/context7.js"
                "${piMcpAdapter}/index.js"
                "${piLsp}/pi-lsp.js"
                "${ponytailPi}/index.js"
                "${config.programs.pi-coding-agent.configDir}/extensions/herdr-agent-state.ts"
              ];
              skills = [
                "${piWebAccess}/skills"
                "${context7Pi}/skills"
                "${ponytailPi}/skills"
              ]
              ++ map (name: toString (skillsDir + "/${name}.md")) skillNames;
            };
          };

          programs.mcp.enable = true;

          home.file."${config.programs.pi-coding-agent.configDir}/extensions/herdr-agent-state.ts".source =
            pkgs.herdr-src + "/src/integration/assets/pi/herdr-agent-state.ts";

          home.file."${config.programs.pi-coding-agent.configDir}/lsp.json".text = builtins.toJSON {
            servers = {
              biome = {
                command = [
                  "biome"
                  "lsp-proxy"
                ];
                extensions = [
                  ".astro"
                  ".css"
                  ".graphql"
                  ".gql"
                  ".html"
                  ".js"
                  ".jsx"
                  ".json"
                  ".jsonc"
                  ".ts"
                  ".tsx"
                  ".vue"
                ];
              };
              ts_ls = {
                command = [
                  "typescript-language-server"
                  "--stdio"
                ];
                extensions = [
                  ".ts"
                  ".tsx"
                  ".js"
                  ".jsx"
                  ".mts"
                  ".cts"
                ];
              };
              ruff = {
                command = [
                  "ruff"
                  "server"
                ];
                extensions = [
                  ".py"
                  ".pyi"
                ];
              };
              ty = {
                command = [
                  "ty"
                  "server"
                ];
                extensions = [
                  ".py"
                  ".pyi"
                ];
              };
              bashls = {
                command = [
                  "bash-language-server"
                  "start"
                ];
                extensions = [
                  ".sh"
                  ".bash"
                ];
              };
              nixd = {
                command = [ "nixd" ];
                extensions = [ ".nix" ];
              };
              gopls = {
                command = [ "gopls" ];
                extensions = [ ".go" ];
              };
              jsonls = {
                command = [
                  "vscode-json-language-server"
                  "--stdio"
                ];
                extensions = [
                  ".json"
                  ".jsonc"
                ];
              };
              yamlls = {
                command = [
                  "yaml-language-server"
                  "--stdio"
                ];
                extensions = [
                  ".yaml"
                  ".yml"
                ];
              };
              lua_ls = {
                command = [ "lua-language-server" ];
                extensions = [ ".lua" ];
              };
              harper_ls = {
                command = [
                  "harper-ls"
                  "--stdio"
                ];
                extensions = [
                  ".md"
                  ".txt"
                  ".typ"
                ];
                initialization = {
                  "harper-ls" = {
                    linters = {
                      boring_words = true;
                      linking_verbs = true;
                      sentence_capitalization = false;
                    };
                    codeActions.forceStable = true;
                  };
                };
              };
              rumdl = {
                command = [
                  "rumdl"
                  "server"
                ];
                extensions = [ ".md" ];
              };
              tombi = {
                command = [
                  "tombi"
                  "lsp"
                ];
                extensions = [ ".toml" ];
              };
            };
          };
        };
    };
}
