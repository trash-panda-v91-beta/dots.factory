#!/usr/bin/env -S just --justfile

set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    @just --list

# Bootstrap system (setup SSH keys and sync configuration)
bootstrap username=`whoami`:
    #!/usr/bin/env bash
    echo "Bootstrapping system for user '{{ username }}'..."
    mkdir -p ~/.ssh
    op read "op://Private/SSH Private Key/private key" > ~/.ssh/{{ username }}
    chmod 600 ~/.ssh/{{ username }}
    echo "SSH key created at ~/.ssh/{{ username }}"
    just sync

# Build darwin configuration for specified hostname
build hostname=`hostname -s`:
    #!/usr/bin/env bash
    GH_TOKEN=$(op read "op://Private/dots.vault Read Access/password")
    echo "Building configuration for '{{ hostname }}' ..."
    NIX_CONFIG="access-tokens = github.com=$GH_TOKEN" nh darwin build . --hostname {{ hostname }}

# Validate quickfix flake configuration and check for errors
check:
    nix flake check

# Run garbage collection keeping specified number of generations
clean keep="3":
    sudo NIX_CONFIG="extra-experimental-features = nix-command flakes" nh clean all --keep {{ keep }}

# Show diff between current and new configuration
diff hostname=`hostname -s`:
    #!/usr/bin/env bash
    GH_TOKEN=$(op read "op://Private/dots.vault Read Access/password")
    echo "Calculating diff for '{{ hostname }}' ..."
    NIX_CONFIG="access-tokens = github.com=$GH_TOKEN" nh darwin build . --hostname {{ hostname }} --dry

# Build and activate darwin configuration for specified hostname
sync hostname=`hostname -s`:
    #!/usr/bin/env bash
    GH_TOKEN=$(op read "op://Private/dots.vault Read Access/password")
    echo "Building and switching to configuration for '{{ hostname }}' ..."
    NIX_CONFIG="access-tokens = github.com=$GH_TOKEN" nh darwin switch . --hostname {{ hostname }}

# Update all flake inputs to their latest versions
update input="":
    #!/usr/bin/env bash
    GH_TOKEN=$(op read "op://Private/dots.vault Read Access/password")
    NIX_CONFIG="access-tokens = github.com=$GH_TOKEN" nix flake update {{ input }}

# Update flake inputs and sync configuration
upgrade hostname=`hostname -s`:
    #!/usr/bin/env bash
    echo "Updating flake inputs and syncing for '{{ hostname }}' ..."
    just update
    just sync {{ hostname }}
