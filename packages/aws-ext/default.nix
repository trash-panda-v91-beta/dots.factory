{ buildNpmPackage, importNpmLock, fetchFromGitHub }:
buildNpmPackage {
  name = "aws";
  src = fetchFromGitHub {
    owner = "raycast";
    repo = "extensions";
    rev = "870667fc671801a467deb7c4c7fc72992efe3820";
    hash = "sha256-sJAU3JmylNuCqhZxWoTQMgf8bBPtiPdVGUw/S/O661w=";
    sparseCheckout = [ "/extensions/amazon-aws" ];
  } + "/extensions/amazon-aws";
  inherit (importNpmLock) npmConfigHook;
  npmDeps = importNpmLock { npmRoot = ./.; };
  npmFlags = [ "--ignore-scripts" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r "$HOME/.config/raycast/extensions"/*/. $out/
    runHook postInstall
  '';
}
