{ buildNpmPackage, importNpmLock }:
buildNpmPackage {
  name = "herdr";
  src = ./.;
  inherit (importNpmLock) npmConfigHook;
  npmDeps = importNpmLock { npmRoot = ./.; };
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    npm run build -- --out $out
    runHook postInstall
  '';
}
