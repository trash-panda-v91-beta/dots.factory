{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.lint";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    plugins.lint = {
      enable = true;
      lazyLoad.settings = {
        event = [ "BufReadPost" ];
      };

      lintersByFt = {
        "yaml.ghaction" = [
          "actionlint"
          "zizmor"
          "yamllint"
        ];
        "yaml.cloudformation" = [
          "cfn_lint"
          "yamllint"
        ];
        dockerfile = [ "hadolint" ];
        yaml = [ "yamllint" ];
      };

      linters = {
        actionlint = {
          cmd = pkgs.lib.getExe pkgs.actionlint;
          # TODO: remove after https://github.com/mfussenegger/nvim-lint/pull/887 is merged
          args = [
            "-format"
            "{{json .}}"
            "-stdin-filename"
            {
              __raw = ''
                function()
                  return vim.api.nvim_buf_get_name(0)
                end
              '';
            }
            "-"
          ];
        };
        cfn_lint.cmd = pkgs.lib.getExe pkgs.python3Packages.cfn-lint;
        hadolint.cmd = pkgs.lib.getExe pkgs.hadolint;
        yamllint.cmd = pkgs.lib.getExe pkgs.yamllint;
        zizmor.cmd = pkgs.lib.getExe pkgs.zizmor;
      };

      autoCmd = {
        event = [
          "BufEnter"
          "BufWritePost"
          "InsertLeave"
        ];
        callback = {
          __raw = ''
            function()
              -- Try to load the lint module, return early if not loaded yet
              local ok, lint = pcall(require, "lint")
              if not ok then
                return
              end

              local filetype = vim.bo.filetype
              
              -- Skip linting for special buffer types
              if vim.bo.buftype ~= "" then
                return
              end
              
              -- Skip linting for non-lintable filetypes
              local skip_filetypes = { "gitcommit", "gitrebase", "help", "qf" }
              if vim.tbl_contains(skip_filetypes, filetype) then
                return
              end

              -- For GitHub Actions workflows, run from repository root
              -- so actionlint can find .github/actionlint.yaml config
              if filetype == "yaml.ghaction" then
                local repo_root = vim.fs.root(0, ".git")
                if repo_root then
                  lint.try_lint(nil, { cwd = repo_root })
                  return
                end
              end

              lint.try_lint()
            end
          '';
        };
      };
    };

    filetype.pattern = {
      # GitHub Actions workflows
      ".*/%.github/workflows/.*%.ya?ml" = "yaml.ghaction";

      # CloudFormation templates (common patterns)
      ".*cloudformation.*%.ya?ml" = "yaml.cloudformation";
      ".*%-stack%.ya?ml" = "yaml.cloudformation";
      ".*template%.ya?ml" = "yaml.cloudformation";
    };
  };
}
