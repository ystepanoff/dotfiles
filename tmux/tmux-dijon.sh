#!/usr/bin/env zsh
set -uo pipefail

ssh-add
tmux kill-session -t dijon

CONFIG_DIR="$HOME/.config/tmux"

log() { printf '[tmux-dijon] %s\n' "$*" >&2; }
tw() {
  log "$*"
  if ! tmux "$@"; then
    log "FAILED: tmux $*"
    return 1
  fi
}

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

if ! tmux has-session -t home 2>/dev/null; then
  tw new-session -d -s home -n shell || true
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
  "$CONFIG_DIR/ssh-loop.sh deployhost.golf.dijon 'cd /home/dijon/yegor/release-golf-system && bash -l'" || true

# 4) inspect (ssh, cd, activate venv)
tw new-window -t dijon -n inspect \
  "$CONFIG_DIR/ssh-loop.sh deployhost.golf.dijon 'cd /home/dijon/yegor/inspect-golf-system && source venv/bin/activate && exec bash -l'" || true

# 5–7) nested envs (inner tmux per env)
for env in golfdev imgstaging img; do
  tw new-window -t dijon -n "$env" \
     "$CONFIG_DIR/tmux-inner-dijon-env.sh $env" || true
done

# 8) claude (interactive SSO then claude; stay in shell afterward)
tw new-window -t dijon -n claude \
  "zsh -l -i -c 'aws-cia login && cd \$HOME/dijon && claude; exec zsh -l -i'" || true

# 9) codex 
tw new-window -t dijon -n codex \
  "zsh -l -i -c 'cd \$HOME/dijon && codex; exec zsh -l -i'" || true

# 10) nvim-1 (editor)
tw new-window -t dijon -n nvim-1 -c "$HOME/dijon" "nvim" || true

# remove bootstrap if it still exists
tmux kill-window -t dijon:bootstrap 2>/dev/null || true

# --- home session baseline ---
tw rename-window -t home:1 shell 2>/dev/null || \
  tw new-window -t home -n shell || true

# attach/switch
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t dijon
else
  tmux attach -t dijon
fi
