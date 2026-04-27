{ inputs, ... }:
{
  # CMB — private repo (CORP_GIT_HOST).
  # PMB builds: nixpkgs has no flakeModules → guard below returns [].
  # CMB builds: --override-input corpo path:../dots.corpo
  imports =
    if inputs ? corpo && inputs.corpo ? flakeModules && inputs.corpo.flakeModules ? default
    then [ inputs.corpo.flakeModules.default ]
    else [ ];
}
