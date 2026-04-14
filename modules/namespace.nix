# Register the `dots` namespace for angle-bracket imports.
# This enables: <dots/terminal>, <dots/editor>, etc.
{ inputs, den, ... }:
{
  imports = [ (inputs.den.namespace "dots" false) ];
  _module.args.__findFile = den.lib.__findFile;
}
