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

host_options=()
for ((i=1; i<=${#hosts}; i++)); do
  host_options+=( "${names[i]}|${hosts[i]}" )
done

export TMUX=

TMUX_BIN=( tmux -L "$SOCK_NAME" )
[[ -f "$INNER_CONF" ]] && TMUX_BIN+=( -f "$INNER_CONF" )

"${TMUX_BIN[@]}" set -g remain-on-exit on 2>/dev/null || true

if ! "${TMUX_BIN[@]}" has-session -t "$SESSION_NAME" 2>/dev/null; then
  "${TMUX_BIN[@]}" new-session -d -s "$SESSION_NAME" -n shell "zsh -l"
fi

"${TMUX_BIN[@]}" set-option -g @host_options "${host_options[*]}"
"${TMUX_BIN[@]}" select-window -t "$SESSION_NAME:1" 2>/dev/null || true

exec "${TMUX_BIN[@]}" attach -t "$SESSION_NAME"
