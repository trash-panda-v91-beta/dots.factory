# Root aspects for category namespaces.
# These exist so sub-provides like dots.tool._.git, dots.bundle._.dev,
# dots.platform._.nix, dots.rice._.cyberdream-dark, dots.tool._.nixvim
# have a parent aspect to attach to. Without these declarations the
# angle-bracket resolver (`<dots/tool/git>` etc.) cannot find the path.
{ ... }:
{
  dots.tool = { };
  dots.bundle = { };
  dots.platform = { };
  dots.rice = { };
}
