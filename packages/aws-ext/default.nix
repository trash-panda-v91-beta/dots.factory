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
      rev = "e0511c9b16807959defd661f91c435745b1342c9";
      hash = "sha256-CUfqboGTdlUd86o4X9stIpvqg8KEtyPECL8FnSEnrt8=";
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
