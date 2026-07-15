{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "pi-nvim";
  src = inputs.pi-nvim;
  version = inputs.pi-nvim.shortRev;

  postPatch = ''
    sed -i \
      -e 's/relative = "editor",/relative = "cursor",/g' \
      -e 's/row = top_row,/row = 1,/' \
      -e 's/row = input_row,/row = info_height + 2 + gap + 1,/' \
      -e 's/col = col,/col = 0,/g' \
      lua/pi-nvim/ui.lua
  '';
}
