{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sable";
  version = "1.22.10-nightly.261009204358.2376b9629f1d";

  # ponytail: repackaging the upstream universal build, not compiling Sable
  # (Tauri + wasm + pnpm) from source - that machine buys nothing for a dotfiles
  # host. Nightlies publish per push to main; bump `version` and `hash` to track.
  src = fetchurl {
    url = "https://git.sable.moe/SableClient/sable-next/releases/download/nightly-${version}/sable-next-${version}-macos-universal.app.tar.gz";
    hash = "sha256-fw/t8AdZfB9ogEvIsrQ/zuvB2U00TYgjceNLBw1Ret4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    tar -xzf "$src" -C $out/Applications
    runHook postInstall
  '';

  meta = {
    description = "Sable Next nightly - Matrix client rewrite in Svelte and Rust";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    license = lib.licenses.agpl3Only;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
