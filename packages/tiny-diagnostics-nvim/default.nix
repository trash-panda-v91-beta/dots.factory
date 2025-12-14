{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "tiny-diagnostics-nvim";
  src = inputs.tiny-diagnostics-nvim;
  version = inputs.tiny-diagnostics-nvim.shortRev;
}
