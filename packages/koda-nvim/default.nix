{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "koda-nvim";
  src = inputs.koda-nvim;
  version = inputs.koda-nvim.shortRev;
}
