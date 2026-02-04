{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "opencode-nvim";
  src = inputs.opencode-nvim;
  version = inputs.opencode-nvim.shortRev;
  nvimSkipModule = [
    "opencode.types"
    "opencode.throttling_emitter"
    "opencode.ui.topbar"
    "opencode.ui.renderer"
    "opencode.ui.session_picker"
    "opencode.ui.context_bar"
    "opencode.ui.base_picker"
    "opencode.ui.completion.context"
    "opencode.ui.formatter"
    "opencode.ui.reference_picker"
    "opencode.ui.mcp_picker"
    "opencode.ui.footer"
    "opencode.ui.timeline_picker"
    "opencode.ui.prompt_guard_indicator"
    "opencode.ui.ui"
    "opencode.ui.history_picker"
    "opencode.context.chat_context"
    "opencode.context.quick_chat_context"
    "opencode.context.base_context"
    "opencode.health"
    "opencode.opencode_server"
    "opencode.session"
    "opencode.snapshot"
    "opencode.image_handler"
    "opencode.server_job"
    "opencode.history"
    "opencode.context"
    "opencode.git_review"
    "opencode.util"
    "opencode.quick_chat"
    "opencode.variant_picker"
    "opencode.api"
    "opencode.core"
    "opencode.api_client"
    "opencode.event_manager"
  ];
}
