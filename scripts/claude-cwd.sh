#!/bin/sh
# Resolve the right working directory for the `prefix + g` lazygit popup.
# Used by .tmux.conf so lazygit lands where Claude is actually editing.
#
# Resolution order:
#   1. Walk the given pane's process tree; if any pid matches a supervised
#      Claude Code Agent View session's `.pid` (i.e. the user has attached
#      to that agent), return that agent's cwd.
#   2. Otherwise, if any agent sessions exist, return the highest-priority
#      agent's worktree:  needs_input > busy/working > most-recent idle.
#      Handles the common case: the foreground claude pane isn't itself in
#      a worktree, but a background agent is working in `<repo>.<branch>/`
#      or `.claude/worktrees/<id>/`.
#   3. Otherwise, find a `claude` descendant in the pane and return its cwd
#      (the original behavior, for when claude is running locally without
#      Agent View).
#   4. Otherwise, fall back to the pane's current path.

pane_pid="$1"
[ -z "$pane_pid" ] && exit 0

# DFS the descendant tree of $1, printing each pid (including $1 itself).
walk_tree() {
    echo "$1"
    for _c in $(pgrep -P "$1" 2>/dev/null); do
        walk_tree "$_c"
    done
}

# DFS the descendant tree of $1; echo the PID of the first process whose
# command line contains "claude". Used for step 3.
find_claude() {
    for _c in $(pgrep -P "$1" 2>/dev/null); do
        if ps -o command= -p "$_c" 2>/dev/null | grep -q claude; then
            echo "$_c"
            return 0
        fi
        _r=$(find_claude "$_c")
        if [ -n "$_r" ]; then
            echo "$_r"
            return 0
        fi
    done
    return 1
}

cwd=""

# Step 1 + 2 — Agent View resolution (skipped silently if claude/jq missing).
if command -v claude >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    agents=$(claude agents --json 2>/dev/null)
    if [ -n "$agents" ] && [ "$agents" != "[]" ]; then
        # Step 1 — PID-tree match against supervised agent pids.
        agent_pids=$(printf '%s' "$agents" | jq -r '.[].pid' 2>/dev/null)
        if [ -n "$agent_pids" ]; then
            for _p in $(walk_tree "$pane_pid"); do
                if printf '%s\n' "$agent_pids" | grep -qx "$_p"; then
                    cwd=$(printf '%s' "$agents" | jq -r --argjson p "$_p" '
                        .[] | select(.pid == $p) | .cwd
                    ' 2>/dev/null | head -1)
                    [ -n "$cwd" ] && break
                fi
            done
        fi

        # Step 2 — highest-priority agent.
        if [ -z "$cwd" ]; then
            cwd=$(printf '%s' "$agents" | jq -r '
                sort_by(
                    ({"needs_input":0,"busy":1,"working":1,"idle":2,"completed":3,"failed":4,"stopped":5}[.status] // 9),
                    -.startedAt
                )
                | .[0].cwd // empty
            ' 2>/dev/null)
        fi
    fi
fi

# Step 3 — cwd of a claude process running in this pane.
if [ -z "$cwd" ]; then
    claude_pid=$(find_claude "$pane_pid")
    if [ -n "$claude_pid" ]; then
        case "$(uname -s)" in
            Darwin)
                cwd=$(lsof -a -d cwd -p "$claude_pid" -Fn 2>/dev/null \
                    | awk '/^n/ { print substr($0, 2); exit }')
                ;;
            Linux)
                cwd=$(readlink "/proc/$claude_pid/cwd" 2>/dev/null)
                ;;
        esac
    fi
fi

# Step 4 — pane's current path.
if [ -z "$cwd" ]; then
    cwd=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
fi

[ -n "$cwd" ] && [ -d "$cwd" ] && printf '%s\n' "$cwd"
exit 0
