#!/usr/bin/env zsh
set -Eeuo pipefail
unsetopt KSH_ARRAYS

SOCK_NAME="tmux-inner-homelab"
SESSION_NAME="homelab"
INNER_CONF="$HOME/.config/tmux/tmux-inner.conf"
SSH_LOOP="$HOME/.config/tmux/ssh-loop.sh"

hosts=(
  "conway@conway-pi-home.local"
)
names=(
  "conway-pi-home"
)

export TMUX=

tmux -L "$SOCK_NAME" set -g remain-on-exit on 2>/dev/null || true

if ! tmux -L "$SOCK_NAME" has-session -t "$SESSION_NAME" 2>/dev/null; then
  tmux -L "$SOCK_NAME" new-session -d -s "$SESSION_NAME" -n "${names[1]}" \
    "$SSH_LOOP ${hosts[1]}"

  for ((i=2; i<=${#hosts}; i++)); do
    tmux -L "$SOCK_NAME" new-window -t "$SESSION_NAME" -n "${names[i]}" \
      "$SSH_LOOP ${hosts[i]}"
  done
fi

tmux -L "$SOCK_NAME" select-window -t "$SESSION_NAME:1" 2>/dev/null || true

if [[ -f "$INNER_CONF" ]]; then
  exec tmux -L "$SOCK_NAME" -f "$INNER_CONF" attach -t "$SESSION_NAME"
else
  exec tmux -L "$SOCK_NAME" attach -t "$SESSION_NAME"
fi
