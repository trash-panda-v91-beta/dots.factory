{ buildNpmPackage, importNpmLock, fetchFromGitHub }:
buildNpmPackage {
  name = "aws";
  src = fetchFromGitHub {
    owner = "raycast";
    repo = "extensions";
    rev = "3c654737b0d566d3103fcdf72221a9f34664bdf2";
    hash = "sha256-7S2DGFdeTI4jEoSBLbX6iBQcA5d8Ljdu16yfXnQK7V4=";
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
