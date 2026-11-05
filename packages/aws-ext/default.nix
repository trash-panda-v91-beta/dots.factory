{
  buildNpmPackage,
  importNpmLock,
  fetchFromGitHub,
}:
buildNpmPackage {
  name = "aws";
  src =
    fetchFromGitHub {
      owner = "raycast";
      repo = "extensions";
      rev = "568a3b23c434ecdc48788496a7daa865d49cebe7";
      hash = "sha256-9f5q3ZViBSBAjTi4ufysxPu5tHMlrKHySnpfFbO6JWE=";
      sparseCheckout = [ "/extensions/amazon-aws" ];
    }
    + "/extensions/amazon-aws";
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
