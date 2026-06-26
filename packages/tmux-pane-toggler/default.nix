{ lib, pkgs, inputs ? null }:
pkgs.writeShellApplication {
  name = "tmux-pane-toggler";
  runtimeInputs = [ pkgs.tmux ];
  text = builtins.readFile ./src/tmux-pane-toggler.sh;
  meta = {
    description = "Tmux pane toggler script";
    mainProgram = "tmux-pane-toggler";
    license = lib.licenses.mit;
  };
}
