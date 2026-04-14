{ dots, ... }:
{
  dots.feature-github-copilot = {
    description = "GitHub Copilot for nixvim";
    homeManager.programs.nixvim.plugins.copilot-lua.enable = true;
  };
}
