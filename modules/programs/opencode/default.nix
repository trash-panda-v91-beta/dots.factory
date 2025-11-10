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
          history_previous = "pageup";
          history_next = "pagedown";
          messages_half_page_up = "up";
          messages_half_page_down = "down";
        };
      };
    };
  };
}
