{ inputs, ... }:
{
  imports =
    if inputs ? corpo && inputs.corpo ? flakeModules && inputs.corpo.flakeModules ? default
    then [ inputs.corpo.flakeModules.default ]
    else [ ];
}
