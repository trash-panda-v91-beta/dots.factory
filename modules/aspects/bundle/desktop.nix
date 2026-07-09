# Desktop bundle - macOS workstation experience
{ __findFile, ... }:
{
  dots.bundle._.desktop = {
    description = "Workstation: tiling window manager, launcher, keyboard remap";
    includes = [
      <dots/tool/window-manager>
      <dots/tool/vicinae>
      <dots/tool/keyboard>
    ];
  };
}
