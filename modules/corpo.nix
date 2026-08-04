{ inputs, ... }:
{
  # CMB — private repo (corp host).
  # PMB builds: nixpkgs has no flakeModules → guard below returns [].
  # CMB builds: --override-input corpo path:$CORPO_REPO (set via dots.corpo sessionVariables)
  imports =
    if inputs ? corpo && inputs.corpo ? flakeModules && inputs.corpo.flakeModules ? default then
      [ inputs.corpo.flakeModules.default ]
    else
      [ ];
}
