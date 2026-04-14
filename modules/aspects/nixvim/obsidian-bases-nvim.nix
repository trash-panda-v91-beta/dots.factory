{ dots, ... }:
{
  dots.obsidian.includes = [ dots.obsidian._."obsidian-bases-nvim" ];
  dots.obsidian._."obsidian-bases-nvim".homeManager = { pkgs, lib, homeconfig, ... }:
  let
    # Hardcode vaults since we're removing the option layer
    # Override these values as needed
    vaults = [ ];
    homeDir = homeconfig.home.homeDirectory;
    vaultsLua = lib.concatMapStringsSep ",\n" (v: ''
      { name = "${v.name}", path = "${homeDir}/${v.path}" }
    '') vaults;
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
