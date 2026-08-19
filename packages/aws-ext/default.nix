{ buildNpmPackage, importNpmLock, fetchFromGitHub }:
buildNpmPackage {
  name = "aws";
  src = fetchFromGitHub {
    owner = "raycast";
    repo = "extensions";
    rev = "a03e4c58dd53593042397b412413afda7117790e";
    hash = "sha256-q7SM0M0cxTJqqWDkuZo4ay34G5Umv0QIxbvmcT1QJiY=";
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
