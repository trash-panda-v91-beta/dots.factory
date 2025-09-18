{ lib, inputs, ... }:
{
  time.timeZone = lib.mkDefault inputs.secrets.timeZone;
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
