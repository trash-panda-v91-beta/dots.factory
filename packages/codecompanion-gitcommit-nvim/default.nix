{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "codecompanion-gitcommit-nvim";
  src = inputs.codecompanion-gitcommit-nvim;
  version = inputs.codecompanion-gitcommit-nvim.shortRev;
  nvimSkipModule = [
    "codecompanion._extensions.gitcommit.init"
    "codecompanion._extensions.gitcommit.buffer"
    "codecompanion._extensions.gitcommit.generator"
    "config_example_with_history"
  ];

}
