#!/bin/sh
# Print the cwd of a `claude` descendant of the given pane shell PID.
# Falls back to the pane's current path if no claude process or lookup fails.
# Used by the `prefix + g` binding in .tmux.conf to open lazygit in Claude
# Code's actual working directory rather than the parent shell's PWD.
#
# Walks the full descendant tree (not just direct children) so claude launched
# via a wrapper (e.g. `npx claude`, a shell function) is still found.

pane_pid="$1"
[ -z "$pane_pid" ] && exit 0

# DFS the descendant tree of $1; echo the PID of the first process whose
# command line contains "claude". Each recursive call runs in $(...) so
# variable scope is isolated per call.
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

if [ -z "$cwd" ]; then
    cwd=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
fi

echo "$cwd"
