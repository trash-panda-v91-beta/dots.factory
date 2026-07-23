{
  lib,
  stdenvNoCC,
  bun,
  cacert,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pi-neuralwatt";
  version = inputs.pi-neuralwatt.shortRev;

  src = inputs.pi-neuralwatt;

  nativeBuildInputs = [ bun cacert ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-tnTtP75Ztis9irAvcmkS2swJF1K9yevgGp28xtfl9Ak=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$HOME"

    # Remove pnpm lockfile so bun does a fresh install instead of migrating + freezing
    rm -f pnpm-lock.yaml

    bun install --production --ignore-scripts

    for ext in provider command-quotas quota-warnings sub-bar-integration; do
      bun build "extensions/$ext/index.ts" \
        --target=node \
        --format=esm \
        --outfile="$ext.js" \
        --external='@earendil-works/*' \
        --external=typebox
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp provider.js command-quotas.js quota-warnings.js sub-bar-integration.js $out/
    runHook postInstall
  '';

  meta = {
    description = "Neuralwatt model provider extension for Pi coding agent";
    homepage = "https://github.com/aliou/pi-neuralwatt";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
