---
name: keymaps
description: Add or modify keymaps in dots.factory following the mnemonic keymap model. Use when adding a new app launcher, aerospace workspace binding, vicinae shortcut, nvim keymap, herdr binding, or any cross-layer keyboard mapping.
---

# Keymaps skill - dots.factory

This repo uses a **layered mnemonic keymap model** that spans kanata (firmware layer),
aerospace (window manager), vicinae (launcher), nvim (editor), and herdr (terminal
multiplexer). Every layer has one modifier owner. Conflicts are avoided by design, not
by accident.

---

## Mental model: modifier ownership

| Modifier | Owner | Meaning |
|---|---|---|
| (none / tap) | kanata | raw letters and layer-taps |
| `Space` (held) | kanata nav layer | editor-style navigation globally |
| `<letter>+Space` (held) | kanata launch layers | **app launcher** - letter = app mnemonic |
| `ctrl-alt-cmd-shift` (hyper) | aerospace | **instant** workspace jump (no mode change) |
| `ctrl-alt-cmd-shift-p` | aerospace | enter aerospace **launcher mode** |
| launcher mode + letter | aerospace | workspace switch + app open |
| `ctrl+Space` | vicinae | toggle vicinae (system launcher / palette) |
| `Space+<key>` | vicinae shortcuts | vicinae entrypoints via nav layer |
| `<leader>` (nvim) | nvim | **nvim-internal** - all plugin keymaps |
| `ctrl` | nvim / herdr-splits | pane navigation, inner-tool actions |
| `alt+<letter>` | herdr | **cross-app** - herdr tabs, panes, workspaces |

**The invariant**: a modifier should mean the same thing regardless of which app is
focused. `alt+h/j/k/l` always means "move herdr focus left/down/up/right". `ctrl` inside
nvim always means "inner tool action or split navigation".

---

## Layer 1 - kanata (keyboard firmware)

File: `modules/aspects/tool/keyboard/kanata/arsenik/deflayer/base_lt_hrm.kbd`
and companion launch layers in the same file.

### App launchers - `<letter>+Space` (hold)

Pattern: define a `tap-hold` alias on the letter, activating a `layer-while-held` when
space is pressed while holding. The layer fires the action on the `@nav` (space) position.

Existing launchers:
- `t` + Space -> open Ghostty (terminal)
- `b` + Space -> open Zen Browser

Adding a new app launcher (`X` = mnemonic letter):

1. Add alias in `defalias`:
   ```
   xx (tap-hold $tap_timeout $long_hold_timeout x (layer-while-held launch-x))
   open-x (cmd open -a "AppName")
   ```
2. Add the key to the base layer (`@xx` replacing `x`).
3. Add the layer definition:
   ```
   (deflayer launch-x
     _  _  _  _  _  _  _  _  _  _  _
     _  _  _  _  _     _  _  _  _  _
     _  _  _  _  _     _  _  _  _  _
     _  _  _  _  _  _  _  _  _  _  _
               _        @open-x      _
   )
   ```
   The `@open-x` sits in the `@nav` (space thumb) position - that is what gets pressed.

Common mnemonic letters to avoid (taken or reserved):
- `t` terminal, `b` browser, `s`/`d`/`f`/`j`/`k`/`l` HRM (never use for launchers)
- `space` is the nav-layer tap - cannot be a launcher key

Available mnemonic slots: `a` (ai/app), `c` (chat/Slack), `e` (explorer/Finder),
`g` (git), `i` (inbox/Mail), `m` (mist/notes), `n` (nil/notes), `o` (obsidian),
`p` (picker/vicinae), `v` (vicinae), `w` (work), `z` (zoxide/jump)

### Space+nav = vicinae entrypoints

When `Space` is held (nav layer), certain keys can fire vicinae commands instead of
(or in addition to) arrow equivalents. Currently `ctrl+Space` toggles vicinae globally
(set in `vicinae/default.nix`). For additional Space+key vicinae shortcuts, add them
to the nav layer:

```
;; In deflayer navigation, position of the desired key:
@vic-jump   ;; mapped: (cmd open vicinae://providers/zerdr)
```

---

## Layer 2 - aerospace (window manager)

File: `modules/aspects/tool/window-manager.nix`

### Workspace jump - hyper (instant, no mode)

`ctrl-alt-cmd-shift-<letter>` = jump to workspace + optionally open its app.

Current workspaces: `t` terminal, `b` browser, `o` obsidian, `n` nil vault,
`m` mist vault, `c` chat (Slack), `g` back-and-forth toggle, `p` enter launcher mode.

Adding a new workspace:

```nix
mode.main.binding = {
  # ...existing...
  ctrl-alt-cmd-shift-x = [
    "exec-and-forget /usr/bin/open -a \"AppName\""
    "workspace x"
  ];
};
```

Also add an `on-window-detected` rule so the app auto-routes to that workspace:

```nix
on-window-detected = [
  # ...existing...
  {
    "if".app-id = "com.bundle.id";
    run = [ "move-node-to-workspace x" ];
  }
];
```

### Launcher mode - `ctrl-alt-cmd-shift-p` -> single letter

For apps you open less often. In `mode.launcher.binding` add the same letter as a
single keystroke. Always return to main mode after:

```nix
mode.launcher.binding = {
  # ...existing...
  x = [
    "exec-and-forget /usr/bin/open -a \"AppName\""
    "workspace x"
    "mode main"
  ];
};
```

**Mnemonic**: launcher mode letters mirror the kanata app-launch letters exactly. If
you add `x` in kanata launchers, add `x` in aerospace launcher mode too.

---

## Layer 3 - vicinae (system launcher / palette)

File: `modules/aspects/tool/vicinae/default.nix`

Toggle: `ctrl+Space` (set in `global_shortcuts.toggle`).

### Built-in shortcuts

Provider entrypoints get a `shortcut` key in `providers.<id>.entrypoints.<ep>.shortcut`.
Format: `"modifier+KEY"` (modifier = `control`, `super`, `alt`, `shift`, or combos).

Current: clipboard history on `super+control+alt+shift+Y`.

Adding a shortcut:

```nix
providers = {
  # ...existing...
  "@vendor/store.raycast.app-slug".entrypoints.default.shortcut = "control+alt+KEY";
};
```

Or via `config.vicinae.extraProviders` in the host/user config to keep vicinae.nix
generic.

### Space+key -> vicinae

The intended pattern for `Space+<key>` -> vicinae entrypoint is:
1. In kanata nav layer, bind the key to a `cmd` that opens the vicinae URL or fires
   the shortcut via `osascript`.
2. Or use the vicinae shortcut system directly (above) as a system-wide hotkey and
   simply learn that `ctrl+Space` then typing is the primary flow.

Currently `Space+p` is the recommended mnemonic for vicinae (p = palette) - not yet
wired in kanata nav layer (ponytail: add when friction is felt with `ctrl+Space`).

---

## Layer 4 - nvim (editor)

Convention: **`<leader>` for everything plugin-related; `ctrl` for pane/split navigation
and inner-tool actions**.

Leader is `Space` (nvim processes it as Space in normal mode, which does not conflict
with kanata's nav layer because kanata fires on hold, nvim sees a tap).

### Namespace map

| Prefix | Group | Files |
|---|---|---|
| `<leader>/` | misc (clear search, etc.) | `keymaps.nix` |
| `<leader>f` | find (snacks picker) | `snacks-picker.nix` |
| `<leader>g` | git (snacks git pickers) | `snacks-picker.nix` |
| `<leader>l` | lsp jump | `snacks-picker.nix` |
| `<leader>c` | code (run/test/debug/action) | `keymaps-code.nix` |
| `<leader>y` | yank (path utils) | `keymaps.nix` |
| `<leader>t` | testing | `testing.nix` |
| `<C-h/j/k/l>` | split navigation (herdr-splits) | `herdr-splits.nix` |

### Adding a nvim keymap

Pick the right namespace prefix from the table. Add to the appropriate `.nix` file.
If none fits, create a new file at `tool/nixvim/<name>.nix` following the sub-aspect
pattern:

```nix
{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.<name> ];
  dots.tool._.nixvim._.<name>.homeManager = { ... }: {
    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<leader>X<letter>";
        action = "<cmd>...<cr>";
        options.desc = "Short description";
      }
    ];
  };
}
```

### Universal actions - same key, right tool

These actions must always land on the same key regardless of which tool handles them:

| Semantic | nvim key | Notes |
|---|---|---|
| Save | `<C-s>` | map `<C-s>` to `:w<CR>` in n/i/v modes |
| Quit buffer | `<leader>q` | `:bd` or snacks bufdelete |
| Close pane | `<C-w>q` (builtin) | - |
| Find (in file) | `<leader>f/` | snacks lines picker |
| Find (global) | `<leader>fw` | snacks grep |
| Open palette | `<leader><space>` | snacks smart picker |

`<C-s>` and `<leader>q` are **not yet wired** - add them to `keymaps.nix` when
implementing the universal actions layer (ponytail: low friction today, add when
the pattern solidifies across herdr/vicinae too).

---

## Layer 5 - herdr (terminal multiplexer)

Convention: **`alt+<letter>`** for all herdr tab/pane/workspace navigation. This is
the cross-app layer - `alt+h/j/k/l` works identically whether focus is in nvim (via
herdr-splits passthrough) or a raw terminal.

Current bindings (set by herdr itself, not in this repo):
- `alt+h/j/k/l` - move focus between panes
- `alt+t` - new tab, `alt+w` - close tab
- `alt+1..9` - jump to tab by index
- `alt+n/p` - next/previous tab

herdr keybindings are configured in its own config (not this Nix repo). Document
custom bindings in this skill when they are added.

---

## Cross-layer consistency rules

1. **One letter = one app** everywhere: `t`=terminal, `b`=browser, `o`=obsidian,
   `n`=nil, `m`=mist, `c`=chat. Use the same letter in kanata launchers, aerospace
   workspaces, and aerospace launcher mode.

2. **Quit = `q` or `<C-q>`** everywhere: aerospace launcher `esc` exits, vicinae
   `esc` exits, nvim `<leader>q` closes buffer, herdr `alt+w` closes tab.

3. **Save = `<C-s>`** everywhere: wire it in nvim; herdr and vicinae don't have
   "save" but apps like Ghostty pass `<C-s>` through.

4. **Navigation = vim keys** everywhere possible: `h/j/k/l` for directional moves,
   `ctrl` in nvim, `alt` across herdr panes.

5. **Palette / find = `Space`** everywhere: vicinae `ctrl+Space`, nvim `<leader><space>`,
   aerospace launcher mode `ctrl-alt-cmd-shift-p`.

---

## Workflow: adding a new app to the full stack

Given app `X` (mnemonic letter), app bundle ID `com.vendor.X`, app name "AppName":

1. **kanata** - add `@xx` alias + `launch-x` layer + `open-x` cmd in
   `deflayer/base_lt_hrm.kbd`
2. **aerospace** - add `ctrl-alt-cmd-shift-x` in `mode.main.binding`, `x` in
   `mode.launcher.binding`, and `on-window-detected` rule in `window-manager.nix`
3. **vicinae** (optional) - add a provider shortcut if vicinae has an extension for it
4. Test: `mise run build` - no changes needed to nvim unless the app has an nvim plugin

---

## Files quick-reference

| What | File |
|---|---|
| kanata base layer + launchers | `modules/aspects/tool/keyboard/kanata/arsenik/deflayer/base_lt_hrm.kbd` |
| kanata nav layer | `modules/aspects/tool/keyboard/kanata/arsenik/deflayer/navigation_vim.kbd` |
| kanata symbols layer | `modules/aspects/tool/keyboard/kanata/arsenik/deflayer/symbols_lafayette_num.kbd` |
| aerospace workspaces + bindings | `modules/aspects/tool/window-manager.nix` |
| vicinae config + shortcuts | `modules/aspects/tool/vicinae/default.nix` |
| nvim general keymaps | `modules/aspects/tool/nixvim/keymaps.nix` |
| nvim code keymaps | `modules/aspects/tool/nixvim/keymaps-code.nix` |
| nvim picker keymaps | `modules/aspects/tool/nixvim/snacks-picker.nix` |
| nvim split nav (herdr-splits) | `modules/aspects/tool/nixvim/herdr-splits.nix` |
