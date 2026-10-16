{ buildNpmPackage, importNpmLock, fetchFromGitHub }:
buildNpmPackage {
  name = "aws";
  src = fetchFromGitHub {
    owner = "raycast";
    repo = "extensions";
    rev = "c33bf4cb4b9ad70c2b93432ee713ffb7486ed331";
    hash = "sha256-4KfzNYhi+kD903iq8zfOz+PpdqSZCUudX90NthlmIpA=";
    sparseCheckout = [ "/extensions/amazon-aws" ];
  } + "/extensions/amazon-aws";
  inherit (importNpmLock) npmConfigHook;
  npmDeps = importNpmLock { npmRoot = ./.; };
  postPatch = ''
    python3 ${./patch-s3.py}
  '';
  npmFlags = [ "--ignore-scripts" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r "$HOME/.config/raycast/extensions"/*/. $out/
    runHook postInstall
  '';
}
