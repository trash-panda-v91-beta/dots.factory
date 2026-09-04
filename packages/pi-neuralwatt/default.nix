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
  outputHash = "sha256-LnfffjW3iUnUT/LsoL57dwgql/n7DAvoXrLtfAuH7fo=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$HOME"

    # Use our committed lock, not the source's pnpm lock (bun re-migrates it and drifts).
    rm -f package-lock.json pnpm-lock.yaml
    cp ${./bun.lock} bun.lock
    bun install --ignore-scripts

    for ext in provider command-quotas quota-warnings sub-bar-integration; do
      bun build "extensions/$ext/index.ts" \
        --target=node \
        --format=esm \
        --outfile="$ext.js" \
        --external='@earendil-works/*' \
        --external=typebox
      # The bundle embeds the build dir ($PWD), which differs per build/machine;
      # normalize it so the FOD hash is identical on every host.
      sed "s|$PWD|/bundle|g" "$ext.js" > "$ext.js.tmp" && mv "$ext.js.tmp" "$ext.js"
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
