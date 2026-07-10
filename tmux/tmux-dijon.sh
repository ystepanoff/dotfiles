#!/usr/bin/env zsh
set -uo pipefail

CONFIG_DIR="$HOME/.config/tmux"

log() { printf '[tmux-dijon] %s\n' "$*" >&2; }
tw() {
  log "$*"
  if ! tmux "$@"; then
    log "FAILED: tmux $*"
    return 1
  fi
}

# only prompt for ssh passphrase when no key is loaded
ssh-add -l >/dev/null 2>&1 || ssh-add

# idempotent: if the dijon session already exists, just attach.
# set TMUX_DIJON_REBUILD=1 to force kill-and-rebuild.
if tmux has-session -t dijon 2>/dev/null; then
  if [[ "${TMUX_DIJON_REBUILD:-0}" == 1 ]]; then
    log "TMUX_DIJON_REBUILD=1 — killing and rebuilding dijon"
    tmux kill-session -t dijon 2>/dev/null || true
  else
    log "dijon session exists — attaching (TMUX_DIJON_REBUILD=1 to force rebuild)"
    if [[ -n "${TMUX:-}" ]]; then
      exec tmux switch-client -t dijon
    else
      exec tmux attach -t dijon
    fi
  fi
fi

# sanity-check helpers
for f in "$CONFIG_DIR/ssh-loop.sh" "$CONFIG_DIR/tmux-inner-dijon-env.sh"; do
  if [[ ! -x "$f" ]]; then
    log "Helper missing or not executable: $f"
  fi
done

# --- create sessions if missing ---
if ! tmux has-session -t dijon 2>/dev/null; then
  tw new-session -d -s dijon -n golf-4 \
     "$CONFIG_DIR/ssh-loop.sh dijon-golf-4.dijonsystems.com" || true
fi

# --- dijon windows ---

# 1) golf-4 (already created above)

# 2) shell (split left/right, right split vertically)
tw new-window -t dijon -n shell -c "$HOME" || true
tw split-window -t dijon:shell -h -p 50 || true
tw select-pane  -t dijon:shell.2 || true
tw split-window -t dijon:shell -v -p 50 || true
tw select-pane  -t dijon:shell.1 || true

# 3) deploy (auto-reconnect, cd into path)
tw new-window -t dijon -n deploy \
  "$CONFIG_DIR/ssh-loop.sh deployhost.golf.dijon 'cd /home/dijon/yegor/release-golf-system && bash -l -i'" || true

# 4) inspect (ssh, cd, activate venv)
tw new-window -t dijon -n inspect \
  "$CONFIG_DIR/ssh-loop.sh deployhost.golf.dijon 'cd /home/dijon/yegor/inspect-golf-system && source venv/bin/activate && exec bash -l -i'" || true

# 5–7) nested envs (inner tmux per env)
for env in golfdev imgstaging img; do
  tw new-window -t dijon -n "$env" \
     "$CONFIG_DIR/tmux-inner-dijon-env.sh $env" || true
done

# 8) claude (stay in shell afterward)
tw new-window -t dijon -n claude \
  "zsh -l -i -c 'cd \$HOME/dijon && claude; exec zsh -l -i'" || true

# 9) codex 
tw new-window -t dijon -n codex \
  "zsh -l -i -c 'cd \$HOME/dijon && codex; exec zsh -l -i'" || true

# 10) nvim-1 (editor)
tw new-window -t dijon -n nvim-1 -c "$HOME/dijon" "nvim" || true

# remove bootstrap if it still exists
tmux kill-window -t dijon:bootstrap 2>/dev/null || true

# attach/switch
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t dijon
else
  tmux attach -t dijon
fi
