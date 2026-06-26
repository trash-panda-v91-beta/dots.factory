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

  # After install, index.js lives at $out/index.js and hooks/ at $out/hooks/.
  # Fix all paths that would otherwise escape $out:
  #   - pi-extension/index.js requires('../hooks/...') -> require('./hooks/...')
  #   - hooks/ponytail-instructions.js resolves '../skills/...' via __dirname -> './skills/...'
  postPatch = ''
    substituteInPlace pi-extension/index.js \
      --replace-fail '../hooks/ponytail-config.js'       './hooks/ponytail-config.js' \
      --replace-fail '../hooks/ponytail-instructions.js' './hooks/ponytail-instructions.js'
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
    cp -r hooks $out/
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
