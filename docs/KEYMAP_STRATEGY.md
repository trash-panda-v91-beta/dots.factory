# Keymap Strategy

This document defines the keymap philosophy and structure across the entire system, from OS-level to application-specific bindings.

---

## Global Modifier Hierarchy

### Philosophy

Clear separation of concerns across modifier keys creates a consistent mental model:
- **Super/Cmd** → System and window management
- **Alt/Hyper** → Context switching and cross-application navigation  
- **Ctrl** → Within-application operations
- **Leader** → Neovim-specific namespace

**Core Rule:** Ctrl is for operations within a single app's context. Alt is for cross-app context switching.

---

### Modifier Layers

#### Super/Cmd (System Layer)
- **Purpose:** OS and desktop-level operations
- **Scope:** Global, works regardless of focused application
- **Examples:** macOS system shortcuts (Cmd-C, Cmd-V, Cmd-Space)

#### Alt/Hyper (Context-Switching Layer)
- **Purpose:** Cross-application navigation and context switching
- **Scope:** Moving between apps, sessions, panes, or switching contexts
- **Pattern:** Use Alt or Hyper keys for this layer
- **Key Examples:**
  - `Alt-s` → Switch tmux sessions
  - `Alt-i` → Open OpenCode from tmux (cross-app launch)
  - `Alt-p` → Previous tmux session
  - `Alt-hjkl` → Resize tmux panes
  - `Alt-t` → Toggle tmux pane visibility
  - `Alt-x` → Kill tmux pane
  - `Alt-v` → Enter tmux copy mode (context switch)
  - `Alt-w` → Last tmux window
  - `Ctrl-Alt-Cmd-Shift-{t,b,g}` → Aerospace workspace switching (hyper keys)

**Rule:** If the action crosses application boundaries or switches contexts, use Alt/Hyper.

#### Ctrl (Application Layer)
- **Purpose:** Operations within a single application's context
- **Scope:** Commands that work only when the app has focus
- **Examples:**
  - OpenCode: `Ctrl-b` (sidebar), `Ctrl-l` (sessions), `Ctrl-p` (palette), etc.
  - Neovim: `Ctrl-s` (CodeCompanion quick toggle)

**Rule:** If the action is specific to one application's context, use Ctrl.

#### Leader (Neovim Layer)
- **Purpose:** Neovim command namespace
- **Scope:** Only works within Neovim
- **See detailed documentation below**

---

### Guidelines for New Keymaps

1. **Determine scope:**
   - System-wide → Super/Cmd
   - Cross-app/context switching → Alt/Hyper
   - Within-app operation → Ctrl
   - Neovim-only → Leader

2. **Check for conflicts** in the same layer

3. **Modal TUIs** (Yazi, lazygit) can use modifier-less keys

4. **Conflict priority:** System > Context-switching > Application > Neovim

---

## Neovim Keymap Strategy

This section defines the philosophy, structure, and conventions for organizing keymaps in this Neovim configuration.

### Neovim-Specific Philosophy

**Core Principles:**
1. **Mnemonic First** - Keys should match their function (c=code, g=git, s=sidekick/AI, etc.)
2. **Discoverability** - Use which-key groups to make keymaps learnable
3. **Consistency** - Follow established patterns across all keymap groups
4. **Muscle Memory** - Avoid conflicts and unnecessary changes
5. **Speed & Ergonomics** - Common operations should be quick to access

## Leader Key

- **Leader**: `<space>` (Space bar)
- **Local Leader**: `<space>` (Same as leader)

The space bar is chosen for its accessibility and comfort.

## Keymap Structure

### Top-Level Groups

Each leader group serves a distinct purpose:

| Prefix | Group | Icon | Purpose |
|--------|-------|------|---------|
| `<leader>s` | Sidekick | 🤖 | AI assistance (Sidekick, CodeCompanion, Copilot) |
| `<leader>a` | *Reserved* | - | Future: Additional AI or Actions |
| `<leader>b` | Buffers | 󰓩 | Buffer management and navigation |
| `<leader>c` | Code | 💻 | Language-specific code actions |
| `<leader>d` | Debug | 🐛 | Debugging operations (DAP) |
| `<leader>e` | *Terminal* | - | Quick terminal toggle |
| `<leader>f` | Find | 🔍 | Fuzzy finding (files, buffers, text, etc.) |
| `<leader>g` | Git | 󰊢 | Git operations and navigation |
| `<leader>l` | LSP | 💡 | LSP operations (definitions, references, etc.) |
| `<leader>n` | Notifications | 󰎟 | Notification management |
| `<leader>q` | Quit/Session | 󰗼 | Session and quit operations |
| `<leader>r` | Replace/Refactor | 🔄 | Search & replace (grug-far), refactoring |
| `<leader>t` | Terminal/Test | 󰙨 | Terminal and test operations |
| `<leader>u` | UI | 󰙵 | UI toggles and configuration |
| `<leader>w` | Windows | 󱂬 | Window management |
| `<leader>x` | Diagnostics | 󱖫 | Diagnostics and quickfix list |

### Special Prefixes

| Prefix | Group | Purpose |
|--------|-------|---------|
| `[` | Previous | Navigate to previous item (diagnostic, hunk, etc.) |
| `]` | Next | Navigate to next item |
| `g` | Goto | Vim-style goto operations (gd, gD, gR, etc.) |
| `gs` | Surround | Mini.surround text objects |

### Quick Access Keys

Some operations are so common they deserve non-leader bindings:

| Key | Action | Reason |
|-----|--------|--------|
| `<leader><space>` | Smart file finder | Most common operation |
| `<leader>e` | Toggle terminal | Quick terminal access |
| `<leader>/` | Clear search highlight | Frequently needed |
| `<C-s>` | Toggle CodeCompanion | Quick AI access from any mode |
| `<Tab>` | Next edit suggestion | AI-assisted coding |

## Patterns & Conventions

### 1. Double-Letter Pattern (Major Toggles)

Use double letters for toggling major UI features:

| Keymap | Action | Note |
|--------|--------|------|
| `<leader>ss` | Toggle CodeCompanion chat | Main AI interface |
| `<leader>gg` | Toggle Neogit/Git status | Main Git interface |

**When to use:** For primary interfaces that you toggle frequently.

### 2. Case Sensitivity Pattern (Variants)

Use lowercase for primary actions, uppercase for variants:

**Example: Code group (`<leader>c`)**
```
<leader>cr  → Run code (primary)
<leader>cR  → Run with picker (variant)

<leader>ct  → Test at cursor (primary)
<leader>cT  → Test last (variant)

<leader>cd  → Debug (primary)
<leader>cD  → Debug with picker (variant)
```

**When to use:** When you have a base action and an enhanced/alternative version.

### 3. Nested Groups

Use sub-groups for related operations:

**Example: Git group**
```
<leader>g   → Git (main group)
  <leader>gd → Git Diff (sub-group)
  <leader>gh → Git Hunk (sub-group)
  <leader>gb → Git branches
  <leader>gC → Git commits
```

**Example: AI/Sidekick group**
```
<leader>s   → Sidekick (main group)
  <leader>sg → GitHub Copilot (sub-group)
    <leader>sgc → Toggle Copilot completions
```

**When to use:** When you have 3+ related operations under a prefix.

### 4. Mode-Specific Keymaps

Some keymaps work differently based on mode:

**Example: AI sending operations**
```
<leader>st → Send "this" (n+v: context-aware)
<leader>sf → Send file (n: current file)
<leader>sv → Send selection (v: visual selection only)
```

**Best practice:** 
- Use the same key for similar operations across modes
- Make visual-only operations obvious (like `sv` for selection)

### 5. Mnemonic Letter Choice

Choose letters that match the action:

| Letter | Common Meanings |
|--------|----------------|
| `a` | Action, Add, AI |
| `c` | Code, Completions, Chat, Config |
| `d` | Debug, Delete, Diff, Definition |
| `e` | Edit, Error, Expand, Explorer |
| `f` | Find, File, Format |
| `g` | Git, Goto, Generate |
| `h` | Help, Hover, History, Hunk |
| `i` | Implementation, Inline, Info |
| `l` | LSP, List, Last, Log |
| `o` | Open, Options |
| `p` | Project, Prompt, Parent |
| `r` | Run, Rename, Replace, References, Refactor |
| `s` | Search, Send, Sidekick, Symbol, Selection |
| `t` | Test, Terminal, This, Toggle, Type |
| `w` | Window, Word, Workspace |

## Detailed Group Specifications

### `<leader>s` - Sidekick (AI Hub)

All AI-related tools are consolidated under this group.

**Philosophy:** One place for all AI assistance.

**Keymaps:**
```
<C-s>         → Quick CodeCompanion toggle (works in n/v/i modes)
<leader>ss    → CodeCompanion Chat toggle
<leader>so    → Toggle OpenCode Sidekick panel
<leader>si    → CodeCompanion inline prompt
<leader>st    → Send "this" (context-aware: function/file/etc.)
<leader>sf    → Send current file
<leader>sv    → Send selection (visual mode only)
<leader>sp    → Select AI prompt
<leader>sa    → CodeCompanion actions menu
<leader>sh    → CodeCompanion history browser
<leader>sc    → Toggle Next Edit Suggestions (NES)
<leader>sg    → GitHub Copilot (sub-group)
  <leader>sgc → Toggle Copilot completions
```

### `<leader>c` - Code

Language-specific and general code operations.

**Philosophy:** Filetype-aware dispatch with graceful fallbacks.

**Pattern:** Uses case sensitivity for variants (see above).

**Keymaps:**
```
<leader>ca  → Code action
<leader>cC  → Open config (Cargo.toml, package.json, etc.)
<leader>cd  → Debug at cursor
<leader>cD  → Debug with picker
<leader>ce  → Explain error
<leader>cE  → Expand macro (language-specific)
<leader>ch  → Hover actions
<leader>cl  → Run last
<leader>cp  → Parent module
<leader>cr  → Run code at cursor
<leader>cR  → Run with picker
<leader>ct  → Test at cursor
<leader>cT  → Test last
```

**Note:** Icons and group names change based on filetype (Rust 🦀, Python 🐍, etc.)

### `<leader>f` - Find

Fuzzy finding for everything.

**Philosophy:** If you're looking for something, it's under `<leader>f`.

**Keymaps:**
```
<leader><space> → Smart files (frecency-based)
<leader>f*      → Find word under cursor/visual (like vim *)
<leader>f,      → Find icons
<leader>f'      → Find marks
<leader>f/      → Fuzzy find in current buffer
<leader>f?      → Fuzzy find in open buffers
<leader>f<CR>   → Resume last find
<leader>fa      → Find autocmds
<leader>fb      → Find buffers
<leader>fc      → Find commands
<leader>fC      → Find config files
<leader>fd      → Find diagnostics (buffer)
<leader>fD      → Find diagnostics (workspace)
<leader>fe      → File explorer
<leader>ff      → Find files
<leader>fF      → Find files (including hidden/ignored)
<leader>fG      → Find git files
<leader>fh      → Find help tags
<leader>fk      → Find keymaps
<leader>fm      → Find man pages
<leader>fo      → Find old/recent files
<leader>fO      → Find Smart (frecency)
<leader>fp      → Find projects
<leader>fq      → Find quickfix list
<leader>fr      → Find registers
<leader>fR      → Rename file
<leader>fs      → Find LSP symbols
<leader>fS      → Find spelling suggestions
<leader>fu      → Find undo history
<leader>fw      → Live grep (find words in files)
<leader>fW      → Live grep (all files)
```

### `<leader>r` - Replace/Refactor

Search & replace operations using grug-far.

**Philosophy:** Powerful project-wide find & replace.

**Keymaps:**
```
<leader>rr  → Open grug-far (general search & replace)
<leader>rw  → Replace word under cursor
<leader>rf  → Replace in current file
<leader>rs  → Replace selection in file (visual mode)
<leader>rt  → Revise text (AI-powered text editing)
```

### `<leader>g` - Git

Git operations and navigation.

**Keymaps:**
```
<leader>gb  → Git branches
<leader>gC  → Git commits
<leader>gD  → Git diff (hunks)
<leader>gf  → Git log file
<leader>gL  → Git log line

<leader>gd  → Git Diff (sub-group)
<leader>gh  → Git Hunk (sub-group)
```

### `<leader>l` - LSP

LSP-specific operations (beyond goto keymaps).

**Keymaps:**
```
<leader>ld  → LSP definitions (picker)
<leader>li  → LSP implementations (picker)
<leader>lD  → LSP references (picker)
<leader>lt  → LSP type definitions (picker)
```

**Note:** Primary goto operations use `g` prefix (gd, gD, gR, gI, gy) for speed.

### `<leader>e` - Terminal Toggle

**Philosophy:** Quick terminal access without a menu.

**Keymaps:**
```
<leader>e   → Toggle terminal (normal mode)
<leader>e   → Toggle terminal (terminal mode, to close)
<C-\>       → Toggle terminal (alternative, from terminal mode)
```

## Decision Tree for New Keymaps

When adding a new keymap, follow this process:

```
1. Is it a PRIMARY operation used multiple times per minute?
   → YES: Consider a non-leader binding or <leader><key>
   → NO: Continue

2. Does it fit into an existing group?
   → YES: Add it to that group, using mnemonic letters
   → NO: Continue

3. Is it part of a family of related operations (3+)?
   → YES: Create a new top-level group or sub-group
   → NO: Consider if it should exist

4. Does the keymap need to work in multiple modes?
   → YES: Define it for all relevant modes (n, v, i)
   → NO: Define for appropriate mode only

5. Is it a variant of an existing action?
   → YES: Use case sensitivity (uppercase for variant)
   → NO: Use lowercase

6. Is it a toggle for a major interface?
   → YES: Consider double-letter pattern
   → NO: Use standard single-letter

7. Document it in this file!
```

## Examples of Good Keymap Design

### Example 1: Adding a new AI feature

**Scenario:** Want to add "explain code" feature

**Analysis:**
- It's AI-related → Goes under `<leader>s`
- It's a code explanation → Mnemonic letter: `e`
- Needs to work on selection → Support visual mode

**Result:**
```nix
{
  mode = ["n" "v"];
  key = "<leader>se";
  action = "...";
  options.desc = "Explain code";
}
```

### Example 2: Adding a search feature

**Scenario:** Want to search for TODO comments

**Analysis:**
- It's a search/find operation → Goes under `<leader>f`
- Mnemonic letter: `t` for TODO
- Normal mode only

**Result:**
```nix
{
  mode = "n";
  key = "<leader>ft";
  action = "...";
  options.desc = "Find TODOs";
}
```

### Example 3: Adding a code action with variant

**Scenario:** Want to add "format code" with option to format whole file

**Analysis:**
- Code-related → Goes under `<leader>c`
- Mnemonic letter: `f` for format
- Has variant (format file) → Use uppercase `F`

**Result:**
```nix
# Primary: format selection/current block
{
  mode = ["n" "v"];
  key = "<leader>cf";
  action = "...";
  options.desc = "Format code";
}

# Variant: format entire file
{
  mode = "n";
  key = "<leader>cF";
  action = "...";
  options.desc = "Format file";
}
```

## Common Mistakes to Avoid

1. **Don't create overlapping groups**
   - ❌ `<leader>s` for both "Search" and "Sidekick"
   - ✅ Consolidate or rename to avoid conflicts

2. **Don't use non-mnemonic letters**
   - ❌ `<leader>fz` for "Find git files"
   - ✅ `<leader>fG` (mnemonic: Git)

3. **Don't create single-item groups**
   - ❌ A group with only one keymap
   - ✅ Add to existing group or wait until you have 2-3 related items

4. **Don't forget mode specifications**
   - ❌ Visual selection keymap in normal mode only
   - ✅ Specify correct modes: `mode = ["n" "v"]` or `mode = "v"`

5. **Don't skip documentation**
   - ❌ Adding keymaps without updating this file
   - ✅ Always document new groups and significant keymaps

## Maintenance

- **Review quarterly**: Check for unused or conflicting keymaps
- **Update this document**: When adding new groups or patterns
- **Get feedback**: If a keymap feels awkward, reconsider it
- **Evolve**: Patterns can change if there's a compelling reason

## Future Considerations

**Potential additions:**
- `<leader>p` - Package/Plugin management
- `<leader>m` - Marks/Macros
- `<leader>o` - Options/Config quick toggles
- `<leader>a` - Additional AI features or generic "Actions"

**When to add:** Only when you have 3+ related operations that don't fit elsewhere.

---

**Last updated:** 2025-12-07
**Maintained by:** @trash-panda-v91-beta
