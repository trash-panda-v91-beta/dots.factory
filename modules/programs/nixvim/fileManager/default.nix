{ delib, lib, ... }:
delib.module {
  name = "programs.nixvim.fileManager";

  options.programs.nixvim.fileManager = with delib; {
    enable = boolOption true;

    provider = lib.mkOption {
      type = lib.types.enum [
        "mini-files"
        "oil"
        "yazi"
      ];
      default = "yazi";
      description = "Which file manager plugin to use";
    };

    keymaps = {
      toggle = strOption "<leader>e";
      toggleCurrent = strOption "-";
      toggleCwd = strOption "_";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      isMiniFiles = cfg.provider == "mini-files";
      isOil = cfg.provider == "oil";
      isYazi = cfg.provider == "yazi";

      # Extract Lua functions for readability
      miniFilesOpenCurrent = ''
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname ~= "" and vim.bo.buftype == "" then
          MiniFiles.open(bufname)
        else
          MiniFiles.open()
        end
      '';

      # Helper function to create keymaps
      mkKeymap = key: action: desc: {
        mode = "n";
        inherit key action;
        options = {
          inherit desc;
          silent = true;
        };
      };
    in
    {
      # Enable the selected file manager plugin
      programs.nixvim.plugins = {
        oil.enable = isOil;
        yazi.enable = isYazi;

        # mini.files requires special handling due to mini.nvim structure
        mini = lib.mkIf isMiniFiles {
          enable = true;
          modules.files = {
            mappings = {
              close = "<Esc>";
              synchronize = "<CR>";
            };
          };
        };
      };

      # Configure unified keymaps based on the selected provider
      programs.nixvim.keymaps =
        if isMiniFiles then
          [
            (mkKeymap cfg.keymaps.toggle (lib.mkRaw "function() MiniFiles.open() end") "Open file explorer")

            (mkKeymap cfg.keymaps.toggleCurrent (lib.mkRaw "function() ${miniFilesOpenCurrent} end")
              "Open file explorer in current folder"
            )

            (mkKeymap cfg.keymaps.toggleCwd (lib.mkRaw "function() MiniFiles.open(vim.loop.cwd()) end")
              "Open file explorer in cwd"
            )
          ]
        else if isOil then
          [
            (mkKeymap cfg.keymaps.toggle ":Oil<CR>" "Open file explorer")

            (mkKeymap cfg.keymaps.toggleCurrent ":Oil .<CR>" "Open file explorer in current folder")

            (mkKeymap cfg.keymaps.toggleCwd (lib.mkRaw "function() require('oil').open(vim.loop.cwd()) end")
              "Open file explorer in cwd"
            )
          ]
        else if isYazi then
          [
            (mkKeymap cfg.keymaps.toggle ":Yazi<CR>" "Open file explorer")

            (mkKeymap cfg.keymaps.toggleCurrent ":Yazi cwd<CR>" "Open file explorer in current folder")

            (mkKeymap cfg.keymaps.toggleCwd ":Yazi<CR>" "Open file explorer in cwd")
          ]
        else
          [ ];

      # Assertion to validate provider
      assertions = [
        {
          assertion = builtins.elem cfg.provider [
            "mini-files"
            "oil"
            "yazi"
          ];
          message = "nixvim.fileManager: Invalid provider '${cfg.provider}'";
        }
      ];
    };
}
