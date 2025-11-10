#!/usr/bin/env zsh
set -uo pipefail

tmux kill-session -t home

CONFIG_DIR="$HOME/.config/tmux"

log() { printf '[tmux-home] %s\n' "$*" >&2; }
tw() {
  log "$*"
  if ! tmux "$@"; then
    log "FAILED: tmux $*"
    return 1
  fi
}

pick() {
  for cmd in "$@"; do
    local bin="${cmd%% *}"
    if command -v "$bin" >/dev/null 2>&1; then
      printf '%s' "$cmd"
      return 0
    fi
  done
  return 1
}

# sanity-check helpers
for f in "$CONFIG_DIR/ssh_loop.sh"; do
  if [[ ! -x "$f" ]]; then
    log "Helper missing or not executable: $f"
  fi
done

if ! tmux has-session -t home 2>/dev/null; then
  tw new-session -d -s home -n shell -c "$HOME" || true
  tw split-window -t home:shell -h -p 50 || true
  tw select-pane  -t home:shell.2 || true
  tw split-window -t home:shell -v -p 50 || true
  tw select-pane  -t home:shell.1 || true
fi

# 1) shell (already created above)

# 2) claude (interactive SSO then claude; stay in shell afterward)
tw new-window -t home -n claude \
  "zsh -l -i -c 'aws-cia login && cd \$HOME/sandbox/ && claude; exec zsh -l -i'" || true

# 3) codex
tw new-window -t home -n codex \
  "zsh -l -i -c 'cd \$HOME/sandbox/ && codex; exec zsh -l -i'"

# 4) files (yazi > ranger > plain ls)
FM="$(pick "yazi" "ranger" "bash -lc 'ls -la'")"
tw new-window -t home -n files -c "$HOME/sandbox" "$FM" || true

# 5) monitor (btm > htop > top)
MON="$(pick "btm" "htop" "top")"
tw new-window -t home -n monitor "$MON" || true

# 6) nvim-1 (editor)
tw new-window -t home -n nvim-1 -c "$HOME/sandbox" "nvim" || true

# attach/switch
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t home
else
  tmux attach -t home
fi
