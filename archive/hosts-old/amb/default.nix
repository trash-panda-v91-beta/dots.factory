{
  hostname,
  ...
}:
{
  config = {
    networking = {
      computerName = "amb";
      hostName = hostname;
      localHostName = hostname;
    };

    homebrew = {
      taps = [ ];
      brews = [ ];
      masApps = { };
    };
  };
}
