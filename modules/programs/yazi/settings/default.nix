{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.yazi.settings";

  options.programs.yazi.settings = with delib; {
    custom = attrsOption { };
  };

  home.always =
    { myconfig, ... }:
    let
      cfg = myconfig.programs.yazi;

      # Default settings
      defaultSettings = {
        log = {
          enabled = true;
        };

        mgr = {
          ratio = [
            1
            3
            4
          ];
          linemode = "custom";
          show_hidden = true;
          show_symlink = true;
          sort_by = "alphabetical";
          sort_dir_first = true;
          sort_reverse = false;
          sort_sensitive = false;
        };

        pick = {
          open_title = "Open with:";
          open_origin = "hovered";
          open_offset = [
            0
            1
            50
            7
          ];
        };

        preview = {
          tab_size = 2;
          max_width = 600;
          max_height = 900;
          image_filter = "triangle";
          image_quality = 75;
          sixel_fraction = 15;
          ueberzug_scale = 1;
          ueberzug_offset = [
            0
            0
            0
            0
          ];
          wrap = "yes";
        };

        tasks = {
          micro_workers = 10;
          macro_workers = 25;
          bizarre_retry = 5;
          image_alloc = 536870912; # 512MB
          image_bound = [
            0
            0
          ];
          suppress_preload = false;
        };

        which = {
          sort_by = "none";
          sort_sensitive = false;
          sort_reverse = false;
        };

        plugin = {
          preloaders = [
            # Image
            {
              mime = "image/vnd.djvu";
              run = "noop";
            }
            {
              mime = "image/*";
              run = "image";
            }
            # Video
            {
              mime = "video/*";
              run = "video";
            }
            # PDF
            {
              mime = "application/pdf";
              run = "pdf";
            }
          ];

          previewers = [
            {
              name = "*/";
              run = "folder";
              sync = true;
            }
            # Code
            {
              mime = "text/*";
              run = "code";
            }
            {
              mime = "*/xml";
              run = "code";
            }
            {
              mime = "*/javascript";
              run = "code";
            }
            # JSON
            {
              mime = "application/json";
              run = "json";
            }
            # Image
            {
              mime = "image/vnd.djvu";
              run = "noop";
            }
            {
              mime = "image/*";
              run = "image";
            }
            # Video
            {
              mime = "video/*";
              run = "video";
            }
            # PDF
            {
              mime = "application/pdf";
              run = "pdf";
            }
            # Archive
            {
              mime = "application/gzip";
              run = "archive";
            }
            # Fallback
            {
              name = "*";
              run = "file";
            }
          ];
        };
      };
    in
    {
      # Merge default settings with user overrides
      programs.yazi.settings = lib.recursiveUpdate defaultSettings cfg.settings.custom;
    };
}
