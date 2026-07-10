#!/usr/bin/env zsh
set -uo pipefail

CONFIG_DIR="$HOME/.config/tmux"

log() { printf '[tmux-home] %s\n' "$*" >&2; }
tw() {
  log "$*"
  if ! tmux "$@"; then
    log "FAILED: tmux $*"
    return 1
  fi
}

# idempotent: if a fully-built home session already exists, just attach.
# a stub home (<=1 window, e.g. left behind by another script) is rebuilt.
# set TMUX_HOME_REBUILD=1 to force kill-and-rebuild regardless.
if tmux has-session -t home 2>/dev/null; then
  win_count="$(tmux list-windows -t home 2>/dev/null | grep -c .)"
  if [[ "${TMUX_HOME_REBUILD:-0}" == 1 ]]; then
    log "TMUX_HOME_REBUILD=1 — killing and rebuilding home"
    tmux kill-session -t home 2>/dev/null || true
  elif [[ "${win_count:-0}" -le 1 ]]; then
    log "home session is a stub ($win_count window) — killing and rebuilding"
    tmux kill-session -t home 2>/dev/null || true
  else
    log "home session exists — attaching (TMUX_HOME_REBUILD=1 to force rebuild)"
    if [[ -n "${TMUX:-}" ]]; then
      exec tmux switch-client -t home
    else
      exec tmux attach -t home
    fi
  fi
fi

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
for f in "$CONFIG_DIR/ssh-loop.sh" "$CONFIG_DIR/tmux-inner-homelab.sh"; do
  if [[ ! -x "$f" ]]; then
    log "Helper missing or not executable: $f"
  fi
done

if ! tmux has-session -t home 2>/dev/null; then
  tw new-session -d -s home -n shell-1 -c "$HOME" || true
  tw split-window -t home:shell-1 -h -p 50 || true
  tw select-pane  -t home:shell-1.2 || true
  tw split-window -t home:shell-1 -v -p 50 || true
  tw select-pane  -t home:shell-1.1 || true
fi

# 1) shell-1 (already created above)

# 2) shell-2
tw new-window -t home -n shell-2 -c "$HOME" || true

# 3) claude (stay in shell afterward)
tw new-window -t home -n claude \
  "zsh -l -i -c 'cd \$HOME/sandbox/ && claude; exec zsh -l -i'" || true

# 4) codex
tw new-window -t home -n codex \
  "zsh -l -i -c 'cd \$HOME/sandbox/ && codex; exec zsh -l -i'"

# 5) files (yazi > ranger > plain ls)
FM="$(pick "yazi" "ranger" "bash -lc 'ls -la'")"
tw new-window -t home -n files -c "$HOME/sandbox" "$FM" || true

# 6) monitor (btm > htop > top)
MON="$(pick "btm" "htop" "top")"
tw new-window -t home -n monitor "$MON" || true

# 7) homelab (inner tmux with SSH to homelab containers)
tw new-window -t home -n homelab \
  "$CONFIG_DIR/tmux-inner-homelab.sh" || true

# 8) nvim-1 (editor)
tw new-window -a -t home -n nvim-1 \
  "zsh -l -i -c 'cd \$HOME/sandbox && nvim; exec zsh -l -i'" || true

# attach/switch
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t home
else
  tmux attach -t home
fi
