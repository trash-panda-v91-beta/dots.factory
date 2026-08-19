{ buildNpmPackage, importNpmLock }:
buildNpmPackage {
  name = "misdr";
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
