{ dots, ... }:
{
  dots.feature-rust = {
    description = "Rust development (cargo, rustaceanvim)";
    includes = [ dots.runtimes ];
    homeManager.programs.nixvim.plugins.rustaceanvim.enable = true;
  };
}
