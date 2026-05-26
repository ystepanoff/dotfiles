#!/usr/bin/env zsh
set -Eeuo pipefail
unsetopt KSH_ARRAYS

ENV_NAME="${1:?usage: $0 <env> (golfdev|imgstaging|img)}"
SOCK_NAME="tmux-inner-${ENV_NAME}"
INNER_CONF="$HOME/.config/tmux/tmux-inner.conf"
SSH_LOOP="$HOME/.config/tmux/ssh-loop.sh"

case "$ENV_NAME" in
  golfdev)
    services=(albatross spitalfields feed-handler gmm gfm settlement simulator brain stpgamestate xenophoxy)
    ;;
  imgstaging|img)
    services=(albatross spitalfields feed-handler gmm gfm-punch settlement simulator brain stpgamestate xenophoxy-punch)
    ;;
  *)
    echo "Unknown env '$ENV_NAME'" >&2
    exit 1
    ;;
esac

# Build "name|target" pairs for the picker. Stored as a tmux option so the
# inner tmux's keybinding can read it without re-parsing the launcher.
host_options=()
for svc in "${services[@]}"; do
  host_options+=( "${svc}|${svc}.${ENV_NAME}.dijon" )
done

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
