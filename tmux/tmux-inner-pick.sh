#!/usr/bin/env zsh
# Pick a host from the inner tmux's @host_options and open it in a new window.
# Reads space-separated "name|ssh-target" pairs from the @host_options option.
set -euo pipefail
unsetopt KSH_ARRAYS

opts=$(tmux show-option -gv @host_options 2>/dev/null || echo "")
if [[ -z "$opts" ]]; then
  print -u2 "no @host_options set on this inner tmux"
  sleep 1
  exit 0
fi

choice=$(printf '%s\n' ${(s: :)opts} | fzf --with-nth=1 -d '|' --prompt='ssh > ') || exit 0
name="${choice%%|*}"
target="${choice#*|}"

tmux new-window -n "$name" "$HOME/.config/tmux/ssh-loop.sh $target"
