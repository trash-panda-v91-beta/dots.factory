{
  hostname,
  ...
}:
{
  config = {
    networking = {
      computerName = "pmb";
      hostName = hostname;
      localHostName = hostname;
    };
    modules = {
      _1password-gui.enable = true;
      aerospace.enable = true;
      karabiner-elements.enable = true;
      zen-browser.enable = true;
    };
    homebrew = {
      casks = [
        "notion"
      ];
    };
  };
}
