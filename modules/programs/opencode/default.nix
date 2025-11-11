{
  delib,
  ...
}:
delib.module {
  name = "programs.opencode";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode = {
      enable = true;
      settings = {

        keybinds = {
          sidebar_toggle = "ctrl+b";
          session_list = "ctrl+s";
          history_previous = "pageup";
          history_next = "pagedown";
          messages_half_page_up = "up";
          messages_half_page_down = "down";
        };
      };
    };
  };
}
