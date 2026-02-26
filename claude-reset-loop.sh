#!/usr/bin/env bash
# claude-reset-loop — Runs Claude in an infinite loop.
#
# Each session, Claude reads an instruction file and does its task.
# When done, Claude drops a sentinel file to signal completion.
# This script detects it, kills Claude, and starts a fresh session.
#
# Usage: claude-reset-loop [-f instruction-file] [-n max-turns] [-a agent]

set -euo pipefail

PROJECT_DIR="$(pwd)"
SENTINEL_FILE="$PROJECT_DIR/please-reset-loop"
INSTRUCTION_FILE="CLAUDE.md"
MAX_TURNS=0        # 0 = run forever
AGENT=""           # optional: launch a specific Claude agent
TURN=0

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -f) INSTRUCTION_FILE="$2"; shift 2 ;;
    -n) MAX_TURNS="$2"; shift 2 ;;
    -a) AGENT="$2"; shift 2 ;;
    *) echo "Usage: $0 [-f instruction-file] [-n max-turns] [-a agent]" >&2; exit 1 ;;
  esac
done

# Track the current Claude PID so cleanup() can find it on Ctrl+C
CLAUDE_PID=""

# Graceful shutdown on Ctrl+C — kills Claude before exiting
cleanup() {
  echo "Shutting down..."
  [[ -n "$CLAUDE_PID" ]] && kill_tree "$CLAUDE_PID"
  exit 0
}
trap cleanup INT TERM

# Kill a process and every subprocess it spawned, recursively.
# Needed because Claude may launch sub-agents as child processes.
kill_tree() {
  local pid=$1
  local children
  children=$(pgrep -P "$pid" 2>/dev/null || true)
  for child in $children; do
    kill_tree "$child"
  done
  kill "$pid" 2>/dev/null || true
}

# Launch Claude, watcher kills it when sentinel appears.
run_with_sentinel() {
  rm -f "$SENTINEL_FILE"

  local agent_flag=""
  [[ -n "$AGENT" ]] && agent_flag="--agent $AGENT"

  echo "$1" | (cd "$PROJECT_DIR" && claude --dangerously-skip-permissions $agent_flag) &
  CLAUDE_PID=$!

  # Sentinel watcher in the background — kills Claude when it drops the file
  (while kill -0 "$CLAUDE_PID" 2>/dev/null; do
    if [[ -f "$SENTINEL_FILE" ]]; then
      sleep 2
      kill_tree "$CLAUDE_PID" 2>/dev/null || true
      break
    fi
    sleep 1
  done) &
  local watcher_pid=$!

  wait "$CLAUDE_PID" 2>/dev/null || true
  kill "$watcher_pid" 2>/dev/null || true
  rm -f "$SENTINEL_FILE"
}

# Bail early if the instruction file doesn't exist
if [[ ! -f "$INSTRUCTION_FILE" ]]; then
  echo "Error: instruction file '$INSTRUCTION_FILE' not found in $(pwd)" >&2
  exit 1
fi

# Restart forever (or up to MAX_TURNS). Each iteration is a fresh Claude session.
while true; do
  TURN=$((TURN + 1))
  [[ "$MAX_TURNS" -gt 0 ]] && echo "Starting (turn $TURN/$MAX_TURNS)..." || echo "Starting (turn $TURN)..."
  run_with_sentinel "Read $INSTRUCTION_FILE and act."
  if [[ "$MAX_TURNS" -gt 0 && "$TURN" -ge "$MAX_TURNS" ]]; then
    echo "Reached max turns ($MAX_TURNS). Done."
    exit 0
  fi
  echo "Restarting in 3s..."
  sleep 3
done
