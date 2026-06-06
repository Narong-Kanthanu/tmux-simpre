# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal tmux configuration distributed as three artifacts:

- `.tmux.conf` — the config users symlink to `~/.tmux.conf`
- `scripts/claude-cwd.sh` — POSIX `/bin/sh` helper invoked from the config
- `install.sh` — symlink installer

There is no build, no test suite, and no package. "Shipping" means committing edits to `.tmux.conf` / `scripts/`; users pull and re-run `install.sh` (or just reload tmux, since the install is symlink-based).

## Install / reload workflow

```sh
bash install.sh                # symlinks .tmux.conf and scripts/ into $HOME (idempotent; prompts before overwriting)
tmux source-file ~/.tmux.conf  # or press prefix + r inside tmux (prefix is C-b)
```

Because `install.sh` uses symlinks, edits to files in this repo take effect on the next reload — re-running `install.sh` is only needed after a fresh clone or if the symlinks are missing. For verification, `readlink ~/.tmux.conf` and `readlink ~/.tmux/scripts` should both point back into this repo.

To test changes without disturbing the user's running tmux, set `TMUX_TMPDIR=/tmp/tmux-test` and start a fresh `tmux -f ./.tmux.conf` server.

## Architecture: the `prefix + g` Claude/lazygit integration

This is the only non-trivial logic in the repo and the most common source of bugs. It spans two files and must be understood as one unit:

1. **`.tmux.conf` (`bind-key 'g'`)** — runs an `if-shell` guard that decides whether the current pane is "a Claude pane." The guard checks `pane_current_command` against `^claude$` or a version-like string (Claude's process name during certain states), then falls back to inspecting one level of child processes via `pgrep -P` for any command containing "claude". This handles wrappers like `npx claude`. Only if the guard passes does it open the lazygit popup.

2. **`scripts/claude-cwd.sh`** — called with `#{pane_pid}` as `$1`; prints the directory lazygit should open in. The four-step resolution order is documented in the script header and **must be preserved in order**:
   1. Walk the pane's full process subtree; if any pid matches a supervised Claude Code [Agent View](https://code.claude.com/docs/en/agent-view) session (`claude agents --json` → `.pid`), return that agent's `.cwd`. This is how attaching to a specific background agent's tmux pane lands lazygit in the right worktree.
   2. Otherwise, if any agents exist, return the highest-priority one by status (`needs_input > busy/working > most-recent idle`). This covers the orchestrator case where the foreground claude isn't itself in a worktree but a background agent is.
   3. Otherwise, find a `claude` descendant in the pane's process tree and read its cwd — `lsof -a -d cwd -p` on macOS, `readlink /proc/<pid>/cwd` on Linux. Platform branching is by `uname -s`.
   4. Otherwise, fall back to `#{pane_current_path}`.

   Steps 1–2 require both `claude` and `jq` on `PATH` and are skipped silently if either is missing — the script still works (degrades to step 3/4). Keep it that way; do not make `jq` a hard dependency.

The script is `/bin/sh` (not bash) and must stay POSIX — `set` builtins, `[ ... ]` tests, no arrays, no `local`. The if-shell guard line in `.tmux.conf` is similarly evaluated by `/bin/sh` via tmux's `run-shell`, so the same constraints apply there.

### When changing this integration

- The guard in `.tmux.conf` and the resolution in `claude-cwd.sh` are layered: the guard decides whether to open lazygit at all, the script decides where. Changing how Claude is detected usually means editing **both** — keep them in sync.
- Test all four resolution steps manually before committing. A change that "works for me" usually means only step 3 or step 4 was exercised.
- macOS uses `lsof`, Linux uses `/proc`. There is no third branch; if you add one (BSD, WSL with quirks, etc.), preserve the existing `case "$(uname -s)"`.

## The `prefix + l` back-to-origin binding and the `@origin` contract

`bind-key 'l'` in `.tmux.conf` reads the `@origin` session option and jumps back to where you came from, falling back to `switch-client -l` (tmux's last-session) when it's unset.

**`@origin` is set by an external launcher, not by this repo.** The contract is: `@origin` holds a tmux **pane id** (e.g. `%5`), not a session name. Because a pane id uniquely identifies its session, window, and pane, the binding restores all three in one hop:

```
switch-client -t "$o" ; select-window -t "$o" ; select-pane -t "$o"
```

The producer today is the companion Neovim config (`lazyvim-nodejs-setup`, `lua/plugins/ai/codecompanion.lua`): when it opens a window in the shared "AI workspace" tmux session, it tags that session with `@origin = $TMUX_PANE` of the pane it was launched from. If you change the value format on either side, change **both** — they are a cross-repo pair.

Backward/forward safety: the `select-window`/`select-pane` calls are suffixed with `2>/dev/null`, so a stale session-name value (the old format) degrades gracefully instead of surfacing a popup error. Keep that.

## Style conventions in this repo

- Catppuccin Macchiato palette via `#{@thm_*}` variables — reuse these instead of hardcoding hex colors when adding status-bar segments.
- Vim-style key bindings (`h/j/k/l`, `v`/`s` for splits) are the user's mental model. New bindings should follow that idiom rather than the tmux defaults.
- Confirm-before for destructive keys (`x` window kill, `Q` session kill). New destructive bindings should do the same.

## Things that look like bugs but aren't

- `prefix + g` does nothing when the current pane isn't running Claude — that's the empty `''` branch of `if-shell` and is intentional.
- `claude-cwd.sh` exits 0 even when it prints nothing; tmux's `display-popup -d ""` then falls back to the pane's cwd. Don't "fix" this by exiting non-zero — it would surface a popup error.
- `automatic-rename-format` shows the basename of the pane's cwd, which can make windows look identically named when you have multiple worktrees of the same repo open. That's a known trade-off, not a bug.
