# Shell Environment

The user's default shell is Nushell (nu), not bash. When providing shell commands or examples:

- Use Nushell syntax by default for interactive commands
- For system operations that require POSIX shell compatibility, explicitly use bash with: `bash -c "command"`
- Common Nushell syntax differences:
  * Environment variables: `$env.VAR_NAME` instead of `$VAR_NAME`
  * Pipes work with structured data, not just text streams
  * Commands return structured data by default
  * Use `^command` to run external commands when name conflicts with Nushell builtins

## Key Command Differences (Bash → Nushell)

**File Operations:**
- `cat file.txt` → `open --raw file.txt` (raw text) or `open file.txt` (structured data)
- `ls -la` → `ls --long --all` or `ls -la`
- `find . -name *.rs` → `ls **/*.rs`

**Output Redirection:**
- `> file` → `out> file` or `o> file` or `| save file`
- `>> file` → `out>> file` or `o>> file` or `| save --append file`
- `2>&1` → `out+err>|` or `o+e>|`
- `> /dev/null` → `| ignore`

**Environment Variables:**
- `echo $PATH` → `$env.PATH` (or `$env.Path` on Windows)
- `echo $?` → `$env.LAST_EXIT_CODE`
- `export FOO=BAR` → `$env.FOO = "BAR"`
- `echo ${FOO:-fallback}` → `$env.FOO? | default "fallback"`

**Iteration & Filtering:**
- `for f in *.md; do echo $f; done` → `ls *.md | each { $in.name }`
- `grep pattern` → `where $it =~ "pattern"` or `find "pattern"`
- `command | head -5` → `command | first 5`

**String Interpolation:**
- Bash: `echo "/tmp/$RANDOM"` → Nushell: `$"/tmp/(random int)"`
- Bash: `cargo build --jobs=$(nproc)` → Nushell: `cargo build $"--jobs=(sys cpu | length)"`

**Command Execution:**
- Sequential: `cmd1 && cmd2` → `cmd1; cmd2`
- Multi-line: `\` → wrap with `( )`, e.g., `(cmd1 | cmd2 | cmd3)`

Examples:
- Nushell: `echo $env.HOME`
- Bash: `bash -c "echo $HOME"`
- External command: `^open file.txt` (when `open` conflicts with Nushell's `open`)
