{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.obsidian";

  options.programs.nixvim.plugins.obsidian = with delib; {
    enable = boolOption true;
    workspaces = listOfOption attrs [ ];
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        plugins.obsidian = {
          enable = true;
          lazyLoad.settings = {
            ft = "markdown";
            after = [ "blink.cmp" ];
          };
          settings = {
            legacy_commands = false;
            workspaces = cfg.workspaces;
            ui.enable = false;

            completion.min_chars = 0;

            # --- Notes ---
            notes_subdir = "";
            new_notes_subdir = "";

            note_id_func.__raw = ''
              function(title)
                if title ~= nil then
                  return title
                else
                  return os.date("%Y-%m-%d %H%M")
                end
              end
            '';

            note_path_func.__raw = ''
              function(spec)
                return (spec.dir / tostring(spec.id)):with_suffix(".md")
              end
            '';

            frontmatter = {
              enabled = true;
              func.__raw = ''
                function(note)
                  local out = {
                    id = note.id,
                    aliases = note.aliases,
                    tags = note.tags,
                  }
                  if note.title ~= nil and note.title ~= note.id then
                    if not note:has_alias(note.title) then
                      note:add_alias(note.title)
                      out.aliases = note.aliases
                    end
                  end
                  if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                    for k, v in pairs(note.metadata) do
                      if out[k] == nil then
                        out[k] = v
                      end
                    end
                  end
                  return out
                end
              '';
            };

            daily_notes = {
              folder = "Daily";
              date_format = "%Y-%m-%d";
              template = "Daily Note Template";
              default_tags = [ "daily" ];
              workdays_only = false;
            };

            templates = {
              folder = "Templates";
              date_format = "%Y-%m-%d";
              time_format = "%H:%M";

              customizations = {
                "Task Template" = {
                  notes_subdir = "Tasks";
                  note_id_func.__raw = ''
                    function(title)
                      local prefix = os.date("%Y-%m-%d %H%M")
                      if title ~= nil and title ~= "" then
                        return prefix .. " " .. title
                      else
                        return prefix
                      end
                    end
                  '';
                };
                "Clipping Template".notes_subdir = "Clippings";
                "Actor Template".notes_subdir = "References";
                "Album Template".notes_subdir = "References";
                "App Template".notes_subdir = "References";
                "Author Template".notes_subdir = "References";
                "Board Game Template".notes_subdir = "References";
                "Book Template".notes_subdir = "References";
                "City Template".notes_subdir = "References";
                "Coffee Template".notes_subdir = "References";
                "Company Template".notes_subdir = "References";
                "Conference Template".notes_subdir = "References";
                "Contact Template".notes_subdir = "References";
                "Director Template".notes_subdir = "References";
                "Event Template".notes_subdir = "References";
                "Food Template".notes_subdir = "References";
                "Movie Template".notes_subdir = "References";
                "Musician Template".notes_subdir = "References";
                "People Template".notes_subdir = "References";
                "Place Template".notes_subdir = "References";
                "Podcast Template".notes_subdir = "References";
                "Podcast Episode Template".notes_subdir = "References";
                "Product Template".notes_subdir = "References";
                "Project Template".notes_subdir = "References";
                "Recipe Template".notes_subdir = "References";
                "Restaurant Template".notes_subdir = "References";
                "Show Template".notes_subdir = "References";
                "Show Episode Template".notes_subdir = "References";
                "Video Game Template".notes_subdir = "References";
              };
            };

            preferred_link_style = "wiki";

            attachments.folder = "Attachments";

            footer = {
              enabled = true;
              separator = false;
            };

            checkbox = {
              enabled = true;
              create_new = false;
            };
          };
        };
      };
    };
}
