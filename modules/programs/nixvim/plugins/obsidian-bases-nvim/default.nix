{
  delib,
  pkgs,
  lib,
  homeconfig,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.obsidian-bases-nvim";

  options.programs.nixvim.plugins.obsidian-bases-nvim = with delib; {
    enable = boolOption false;
    vaults = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            path = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = [ ];
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      homeDir = homeconfig.home.homeDirectory;
      vaultsLua = lib.concatMapStringsSep ",\n" (v: ''
        { name = "${v.name}", path = "${homeDir}/${v.path}" }
      '') cfg.vaults;
      obsidianBin = "${pkgs.obsidian}/bin/obsidian-cli";
    in
    {
      programs.nixvim = {
        extraPlugins = [ pkgs.local.obsidian-bases-nvim ];
        extraConfigLua = ''
          require("obsidian-bases").setup({
            vaults = {
              ${vaultsLua}
            },
            obsidian_bin = "${obsidianBin}",
            auto_render = true,
            picker = "auto",
            render = {
              max_col_width = 40,
              table_highlight = "Comment",
              conceal_embed = true,
            },
            keys = {
              render = "<leader>ub",
              open = "<leader>nb",
              clear = "<leader>ux",
            },
          })
        '';
      };
    };
}
