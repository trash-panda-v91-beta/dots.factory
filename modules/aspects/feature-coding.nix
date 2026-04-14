{ dots, ... }:
{
  dots.feature-coding = {
    description = "Core coding stack";
    includes = [
      dots.terminal
      dots.nixvim
      dots.dev-tools
      dots.ai
    ];
  };
}
