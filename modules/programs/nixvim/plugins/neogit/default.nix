{ delib, lib, ... }:
delib.module {
  name = "programs.nixvim.plugins.neogit";

  options = with lib; {
    enable = delib.singleEnableOption true;
    gitService = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Custom git service hostname for GitHub Enterprise Server";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        plugins.neogit = {
          enable = true;
          settings = lib.mkIf (cfg.gitService != null) {
            git_services = {
              "${cfg.gitService}" = {
                pull_request = "https://${cfg.gitService}/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
                commit = "https://${cfg.gitService}/\${owner}/\${repository}/commit/\${oid}";
                tree = "https://${cfg.gitService}/\${owner}/\${repository}/tree/\${branch_name}";
              };
            };
          };
        };
        keymaps = [
          {
            mode = [ "n" ];
            key = "<leader>gg";
            action = "<cmd>Neogit<cr>";
            options = {
              desc = "Open Neogit";
            };
          }
        ];
      };
    };
}
