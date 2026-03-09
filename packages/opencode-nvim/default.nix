{
  inputs,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "opencode-nvim";
  src = inputs.opencode-nvim;
  version = inputs.opencode-nvim.shortRev;
  nvimSkipModule = [
    "opencode.api"
    "opencode.api_client"
    "opencode.context"
    "opencode.context.base_context"
    "opencode.context.chat_context"
    "opencode.context.quick_chat_context"
    "opencode.core"
    "opencode.event_manager"
    "opencode.git_review"
    "opencode.health"
    "opencode.history"
    "opencode.image_handler"
    "opencode.log"
    "opencode.opencode_server"
    "opencode.quick_chat"
    "opencode.port_mapping"
    "opencode.server_job"
    "opencode.session"
    "opencode.snapshot"
    "opencode.throttling_emitter"
    "opencode.types"
    "opencode.ui.base_picker"
    "opencode.ui.completion.context"
    "opencode.ui.context_bar"
    "opencode.ui.footer"
    "opencode.ui.formatter"
    "opencode.ui.history_picker"
    "opencode.ui.mcp_picker"
    "opencode.ui.prompt_guard_indicator"
    "opencode.ui.reference_picker"
    "opencode.ui.renderer"
    "opencode.ui.session_picker"
    "opencode.ui.timeline_picker"
    "opencode.ui.topbar"
    "opencode.ui.ui"
    "opencode.util"
    "opencode.variant_picker"
  ];
}
