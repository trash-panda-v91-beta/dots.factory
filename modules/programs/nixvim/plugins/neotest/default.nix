{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.neotest";

  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled.programs.nixvim = {
    plugins.neotest = {
      enable = true;

      adapters.python = {
        enable = true;
        settings = {
          runner = "pytest";
          pytest_discover_instances = true;
        };
      };

      settings = {
        status = {
          enabled = true;
          virtual_text = true;
        };
        output = {
          enabled = true;
          open_on_run = "short";
        };
        floating = {
          border = "single";
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action.__raw = "function() require('neotest').run.run() end";
        options.desc = "Run nearest test";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end";
        options.desc = "Run file tests";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action.__raw = "function() require('neotest').summary.toggle() end";
        options.desc = "Toggle test summary";
      }
      {
        mode = "n";
        key = "<leader>to";
        action.__raw = "function() require('neotest').output.open({ enter = true }) end";
        options.desc = "Show test output";
      }
      {
        mode = "n";
        key = "<leader>tO";
        action.__raw = "function() require('neotest').output_panel.toggle() end";
        options.desc = "Toggle output panel";
      }
      {
        mode = "n";
        key = "<leader>tS";
        action.__raw = "function() require('neotest').run.stop() end";
        options.desc = "Stop running tests";
      }
      {
        mode = "n";
        key = "<leader>td";
        action.__raw = "function() require('neotest').run.run({strategy = 'dap'}) end";
        options.desc = "Debug nearest test";
      }
    ];
  };
}
