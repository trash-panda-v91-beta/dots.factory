{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.lint";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.lint = {
      enable = true;
      lazyLoad.settings = {
        event = [ "DeferredUIEnter" ];
      };

      lintersByFt = {
        "yaml.ghaction" = [
          "actionlint"
          "zizmor"
        ];
        "yaml.cloudformation" = [ "cfn_lint" ];
        "json.cloudformation" = [ "cfn_lint" ];
        dockerfile = [ "hadolint" ];
        yaml = [ "yamllint" ];
      };

      linters = {
        actionlint.cmd = pkgs.lib.getExe pkgs.actionlint;
        cfn_lint.cmd = pkgs.lib.getExe pkgs.python3Packages.cfn-lint;
        hadolint.cmd = pkgs.lib.getExe pkgs.hadolint;
        yamllint.cmd = pkgs.lib.getExe pkgs.yamllint;
        zizmor.cmd = pkgs.lib.getExe pkgs.zizmor;
      };
    };

    filetype.pattern = {
      # GitHub Actions workflows
      ".*/%.github/workflows/.*%.ya?ml" = "yaml.ghaction";

      # CloudFormation templates (common patterns)
      ".*cloudformation.*%.ya?ml" = "yaml.cloudformation";
      ".*cloudformation.*%.json" = "json.cloudformation";
      ".*%-stack%.ya?ml" = "yaml.cloudformation";
      ".*template%.ya?ml" = "yaml.cloudformation";
    };
  };
}
