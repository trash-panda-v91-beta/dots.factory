{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "tiny-code-action-nvim";
  src = inputs.tiny-code-action-nvim;
  version = inputs.tiny-code-action-nvim.shortRev or "unstable";
  nvimSkipModules = [
    "tiny-code-action.previewers.snacks"
  ];
}
