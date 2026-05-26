#!/usr/bin/env zsh
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <host> [remote-cmd ...]" >&2
  exit 2
fi

HOST="$1"; shift || true
REMOTE_CMD=( "$@" )

KEEPALIVE_OPTS=(
  -o ServerAliveInterval=60
  -o ServerAliveCountMax=3
  -o TCPKeepAlive=yes
  -o ConnectTimeout=10
  -o ExitOnForwardFailure=no
)

PS1_VALUE='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
SHELL_INIT='source ~/.bashrc 2>/dev/null; export __PS1="'"${PS1_VALUE}"'"; export PROMPT_COMMAND='"'"'PS1="$__PS1"'"'"'; '

delay=2
max_delay=60

while true; do
  start_ts=$(date +%s)
  echo "[ssh_loop] $(date '+%F %T') connecting to ${HOST} (delay=${delay}s) …"
  if [[ ${#REMOTE_CMD[@]} -gt 0 ]]; then
    ssh -tt "${KEEPALIVE_OPTS[@]}" -- "${HOST}" "${SHELL_INIT}${REMOTE_CMD[*]}" || true
  else
    ssh -tt "${KEEPALIVE_OPTS[@]}" -- "${HOST}" "${SHELL_INIT}exec bash --norc" || true
  fi
  code=$?
  end_ts=$(date +%s)
  elapsed=$(( end_ts - start_ts ))

  # Connections that lasted ≥60s reset backoff to 2s. Quick-failing
  # connections back off exponentially up to max_delay.
  if (( elapsed >= 60 )); then
    delay=2
  fi

  echo "[ssh_loop] $(date '+%F %T') ssh exited (code ${code}, lasted ${elapsed}s). Reconnecting in ${delay}s. Press Ctrl-C to stop."
  sleep "$delay"

  if (( delay < max_delay )); then
    delay=$(( delay * 2 ))
    (( delay > max_delay )) && delay=$max_delay
  fi
done
