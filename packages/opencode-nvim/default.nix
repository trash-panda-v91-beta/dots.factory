{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "opencode-nvim";
  src = inputs.opencode-nvim;
  version = inputs.opencode-nvim.shortRev;
  nvimSkipModule = [
    "opencode.ui.footer"
    "opencode.ui.session_formatter"
    "opencode.ui.contextual_actions"
    "opencode.ui.util"
    "opencode.ui.ui"
    "opencode.ui.navigation"
    "opencode"
    "opencode.models"
    "opencode.health"
    "opencode.config_file"
    "opencode.opencode_server"
    "opencode.keymap"
    "opencode.review"
    "opencode.session"
    "opencode.snapshot"
    "opencode.server_job"
    "opencode.history"
    "opencode.context"
    "opencode.git_review"
    "opencode.util"
    "opencode.api"
    "opencode.core"
    "opencode.ui.output_renderer"
  ];

}
