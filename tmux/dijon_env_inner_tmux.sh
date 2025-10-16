#!/usr/bin/env zsh
set -Eeuo pipefail

ENV_NAME="${1:?usage: $0 <env> (golfdev|imgstaging|img)}"
SOCK_NAME="inner-${ENV_NAME}"
INNER_CONF="$HOME/.config/tmux/inner-tmux.conf"
SSH_LOOP="$HOME/.config/tmux/ssh_loop.sh"

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

export TMUX=

if ! tmux -L "$SOCK_NAME" has-session -t "$ENV_NAME" 2>/dev/null; then
  tmux -L "$SOCK_NAME" new-session -d -s "$ENV_NAME" -n "${services[1]}" \
    "$SSH_LOOP ${services[1]}.${ENV_NAME}.dijon"
  for svc in "${services[@]:2}"; do
    tmux -L "$SOCK_NAME" new-window -t "$ENV_NAME" -n "$svc" \
      "$SSH_LOOP ${svc}.${ENV_NAME}.dijon"
  done
fi

tmux -L "$SOCK_NAME" select-window -t "$ENV_NAME:1" 2>/dev/null || true

if [[ -f "$INNER_CONF" ]]; then
  exec tmux -L "$SOCK_NAME" -f "$INNER_CONF" attach -t "$ENV_NAME"
else
  exec tmux -L "$SOCK_NAME" attach -t "$ENV_NAME"
fi
