{
  delib,
  pkgs,
  lib,
  host,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.rustaceanvim";

  options = delib.singleEnableOption host.rustFeatured;

  home.ifEnabled.programs.nixvim = {
    plugins.rustaceanvim = {
      enable = true;
      lazyLoad.settings.ft = "rust";

      settings = {
        dap = {
          adapter = {
            command = lib.getExe' pkgs.lldb "lldb-dap";
            type = "executable";
          };
          autoloadConfigurations = true;
        };

        server = {
          default_settings = {
            rust-analyzer = {
              cargo = {
                buildScripts.enable = true;
                features = "all";
              };

              diagnostics = {
                enable = true;
                styleLints.enable = true;
              };

              checkOnSave = true;
              check = {
                command = "clippy";
                features = "all";
              };

              files = {
                excludeDirs = [
                  ".cargo"
                  ".direnv"
                  ".git"
                  "node_modules"
                  "target"
                ];
              };

              inlayHints = {
                bindingModeHints.enable = true;
                closureStyle = "rust_analyzer";
                closureReturnTypeHints.enable = "always";
                discriminantHints.enable = "always";
                expressionAdjustmentHints.enable = "always";
                implicitDrops.enable = true;
                lifetimeElisionHints.enable = "always";
                rangeExclusiveHints.enable = true;
              };

              procMacro = {
                enable = true;
              };

              rustc.source = "discover";
            };
          };
        };

        tools = {
          enable_clippy = true;
          test_executor = "background";
        };
      };
    };
  };
}
