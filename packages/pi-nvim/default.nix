{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "pi-nvim";
  src = inputs.pi-nvim;
  version = inputs.pi-nvim.shortRev;
}
