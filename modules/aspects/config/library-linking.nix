{ lib, ... }:
{
  dots.library-linking = {
    description = "macOS Library path linking from nix store to /Library";

    darwin =
      { pkgs, config, ... }:
      {
        system.build.applications = lib.mkForce (
          pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = [
              "/Applications"
              "/Library"
            ];
          }
        );

        system.activationScripts.applications.text = lib.mkAfter ''
          echo "setting up library paths for apps..." >&2

          if [ -d "${config.system.build.applications}/Library" ] || [ -e "${config.system.build.applications}/Library" ]; then
            rsyncFlags=(
              --checksum
              --archive
              --copy-unsafe-links
              --chmod=-w
            )

            copy_sub () {
              local subdir="$1"
              local targetFolder="/Library/$subdir"
              mkdir -p "$targetFolder"
              find "$targetFolder" -maxdepth 1 -type d -exec bash -c \
                'folderName=$(basename "$0"); \
                 if [ -d "${config.system.build.applications}/Library/'"$subdir"'/$folderName" ] && [ "$folderName" != "$(basename '"$subdir"')" ]; then \
                   echo "  removing old $0" >&2; \
                   rm -rf "$0"; \
                 fi \
                ' {} \;
              if [ -d "${config.system.build.applications}/Library/$subdir" ]; then
                echo "  copying library paths to $targetFolder" >&2
                ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" "${config.system.build.applications}/Library/$subdir/" "$targetFolder/"
              else
                echo "  no content found for $subdir (skipping)" >&2
              fi
            }

            copy_sub "Application Support"
            copy_sub "Audio"
            copy_sub "Audio/Plugins"
          else
            echo "  no Library directory in system-applications (skipping)" >&2
          fi
        '';
      };
  };
}
