#!/usr/bin/env zsh
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <host> [remote-cmd ...]" >&2
  exit 2
fi

HOST="$1"; shift || true
REMOTE_CMD=( "$@" )

KEEPALIVE_OPTS=(
  -o ServerAliveInterval=15
  -o ServerAliveCountMax=3
  -o TCPKeepAlive=yes
  -o ConnectTimeout=10
  -o ExitOnForwardFailure=no
)

PS1_VALUE='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# Use PROMPT_COMMAND to force PS1 before every prompt, surviving bash -l overrides
SHELL_INIT='source ~/.bashrc 2>/dev/null; export __PS1="'"${PS1_VALUE}"'"; export PROMPT_COMMAND='"'"'PS1="$__PS1"'"'"'; '

while true; do
  echo "[ssh_loop] $(date '+%F %T') connecting to ${HOST} …"
  if [[ ${#REMOTE_CMD[@]} -gt 0 ]]; then
    # -tt to force a TTY so shells/venvs behave; never 'exec' here so the loop survives
    ssh -tt "${KEEPALIVE_OPTS[@]}" -- "${HOST}" "${SHELL_INIT}${REMOTE_CMD[*]}" || true
  else
    ssh -tt "${KEEPALIVE_OPTS[@]}" -- "${HOST}" "${SHELL_INIT}exec bash --norc" || true
  fi
  code=$?
  echo "[ssh_loop] $(date '+%F %T') ssh exited (code ${code}). Reconnecting in 2s. Press Ctrl-C to stop."
  sleep 2
done
