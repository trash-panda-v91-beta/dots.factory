# AWS capability bundle - vicinae extension + tooling
# Enabled on CMB via dots.corpo; not included in the personal PMB user manifest.
{ __findFile, ... }:
{
  dots.bundle._.aws = {
    description = "AWS: vicinae extension, aws-vault, cfn-lsp";
    includes = [ <dots/tool/vicinae> ];

    homeManager =
      { pkgs, ... }:
      {
        xdg.dataFile."vicinae/extensions/store.raycast.aws".source = pkgs.local.aws-ext;
        programs.vicinae.settings.providers."@Falcon/store.raycast.aws".preferences.useAWSVault = false;

        programs.nixvim.extraPackages = [ pkgs.local.cfn-lsp ];
        programs.nixvim.extraConfigLua = ''
          vim.lsp.config('cfn_lsp', {
            cmd = { 'cfn-lsp-server' },
            filetypes = { 'yaml', 'json', 'cfn', 'template' },
            root_markers = { '.git' },
            init_options = {
              aws = {
                clientInfo = { extension = { name = 'neovim', version = '0.12' } },
                telemetryEnabled = false,
              },
            },
          })
          vim.lsp.enable('cfn_lsp')
        '';

        piLspExtraServers.cfn_lsp = {
          command = [ "${pkgs.local.cfn-lsp}/bin/cfn-lsp-server" ];
          extensions = [ ".yaml" ".yml" ".json" ".cfn" ".template" ];
          initialization = {
            aws = {
              clientInfo = { extension = { name = "pi"; version = "1.0.0"; }; };
              telemetryEnabled = false;
            };
          };
        };
      };
  };
}
