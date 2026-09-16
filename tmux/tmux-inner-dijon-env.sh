#!/usr/bin/env zsh
set -Eeuo pipefail
unsetopt KSH_ARRAYS

ENV_NAME="${1:?usage: $0 <env> (golfdev|imgstaging|img|golf)}"
SOCK_NAME="tmux-inner-${ENV_NAME}"
INNER_CONF="$HOME/.config/tmux/tmux-inner.conf"
SSH_LOOP="$HOME/.config/tmux/ssh-loop.sh"
HOSTS_FILE="$HOME/.config/tmux/${ENV_NAME}.txt"

if [[ ! -r "$HOSTS_FILE" ]]; then
  echo "Host list not found: $HOSTS_FILE" >&2
  exit 1
fi

# Build "name|target" pairs for the picker from the env's host list (one
# hostname per line; blank lines and #comments ignored). Stored as a tmux
# option so the inner tmux's keybinding can read it without re-parsing the
# launcher. Display name is the hostname minus ".<env>.dijon" / ".dijon".
host_options=()
while IFS= read -r host; do
  host="${host%%[[:space:]]*}"
  [[ -z "$host" || "$host" == \#* ]] && continue
  name="${host%.${ENV_NAME}.dijon}"
  name="${name%.dijon}"
  host_options+=( "${name}|${host}" )
done < "$HOSTS_FILE"

if (( ${#host_options[@]} == 0 )); then
  echo "No hosts found in $HOSTS_FILE" >&2
  exit 1
fi

export TMUX=

TMUX_BIN=( tmux -L "$SOCK_NAME" )
[[ -f "$INNER_CONF" ]] && TMUX_BIN+=( -f "$INNER_CONF" )

"${TMUX_BIN[@]}" set -g remain-on-exit on 2>/dev/null || true

if ! "${TMUX_BIN[@]}" has-session -t "$ENV_NAME" 2>/dev/null; then
  "${TMUX_BIN[@]}" new-session -d -s "$ENV_NAME" -n shell "zsh -l"
fi

"${TMUX_BIN[@]}" set-option -g @host_options "${host_options[*]}"
"${TMUX_BIN[@]}" select-window -t "$ENV_NAME:1" 2>/dev/null || true

exec "${TMUX_BIN[@]}" attach -t "$ENV_NAME"
