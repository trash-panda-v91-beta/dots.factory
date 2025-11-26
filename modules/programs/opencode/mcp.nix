{
  delib,
  ...
}:
delib.module {
  name = "programs.opencode.mcp";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode.settings.tools = {
      context7 = false;
      github = false;
      hass = false;
    };
  };
}
