{ pkgs, ... }:
pkgs.vimUtils.buildVimPlugin {
  pname = "obsidian-bases-nvim";
  version = "1.0.0";
  src = pkgs.fetchurl {
    url = "https://github.com/trash-panda-v91-beta/obsidian-bases.nvim/archive/refs/tags/v1.0.0.tar.gz";
    hash = "sha256-JxeL3aF2Hb8uWkAAbb/xui573eG7bNTqebAMYfkx+7A=";
  };
  doCheck = false;
}
