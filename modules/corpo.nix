{ inputs, ... }:
{
  # CMB — private repo (github.concur).
  # PMB builds: nixpkgs has no flakeModules → guard below returns [].
  # CMB builds: --override-input corpo path:../dots.corpo
  imports =
    if inputs ? corpo && inputs.corpo ? flakeModules && inputs.corpo.flakeModules ? default
    then [ inputs.corpo.flakeModules.default ]
    else [ ];
}
