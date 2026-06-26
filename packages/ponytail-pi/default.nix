{
  lib,
  stdenvNoCC,
  bun,
  inputs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "ponytail-pi";
  version = inputs.ponytail.shortRev;

  src = inputs.ponytail;

  nativeBuildInputs = [ bun ];

  # The instructions loader resolves the skill file as path.join(__dirname, '..', 'skills', ...).
  # After bundling, __dirname is the bundle's directory ($out), so drop the '..'.
  postPatch = ''
    substituteInPlace hooks/ponytail-instructions.js \
      --replace-fail \
        "path.join(__dirname, '..', 'skills', 'ponytail', 'SKILL.md')" \
        "path.join(__dirname, 'skills', 'ponytail', 'SKILL.md')"
  '';

  buildPhase = ''
    runHook preBuild

    bun build pi-extension/index.js \
      --target=node \
      --format=esm \
      --outfile=index.js \
      --external='@earendil-works/*' \
      --external=typebox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp index.js $out/
    cp -r skills $out/
    runHook postInstall
  '';

  meta = {
    description = "Lazy-senior-dev skill and extension for Pi coding agent";
    homepage = "https://github.com/DietrichGebert/ponytail";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
