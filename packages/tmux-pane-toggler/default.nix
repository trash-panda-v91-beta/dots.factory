{
  inputs,
  lib,
  stdenv,
  pkgs,
}:

let
  myName = "tmux-pane-toggler";
  tmuxPaneToggler = pkgs.writeShellApplication {
    name = "tmux-pane-toggler";
    bashOptions = [ ];
    runtimeInputs = with pkgs; [
      tmux
    ];
    text = builtins.readFile src/tmux-pane-toggler.sh;
  };
in
stdenv.mkDerivation {
  name = myName;
  src = tmuxPaneToggler;
  installPhase = ''
    mkdir -p "$out"
    cp -r * "$out"/bin/
  '';

  meta = {
    description = "Tmux pane toggler script";
    mainProgram = "tmux-pane-toggler";
    license = lib.licenses.mit;
  };
}
