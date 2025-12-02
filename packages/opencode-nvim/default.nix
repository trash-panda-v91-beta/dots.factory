{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "opencode-nvim";
  src = inputs.opencode-nvim;
  version = inputs.opencode-nvim.shortRev;
  nvimSkipModule = [
    "opencode"
    "opencode.api"
    "opencode.api_client"
    "opencode.config_file"
    "opencode.context"
    "opencode.core"
    "opencode.event_manager"
    "opencode.git_review"
    "opencode.health"
    "opencode.history"
    "opencode.image_handler"
    "opencode.keymap"
    "opencode.models"
    "opencode.opencode_server"
    "opencode.review"
    "opencode.server_job"
    "opencode.session"
    "opencode.snapshot"
    "opencode.ui.base_picker"
    "opencode.ui.completion.context"
    "opencode.ui.context_bar"
    "opencode.ui.contextual_actions"
    "opencode.ui.footer"
    "opencode.ui.formatter"
    "opencode.ui.history_picker"
    "opencode.ui.navigation"
    "opencode.ui.output_renderer"
    "opencode.ui.prompt_guard_indicator"
    "opencode.ui.renderer"
    "opencode.ui.session_formatter"
    "opencode.ui.session_picker"
    "opencode.ui.timeline_picker"
    "opencode.ui.topbar"
    "opencode.ui.ui"
    "opencode.ui.util"
    "opencode.util"
  ];

}
