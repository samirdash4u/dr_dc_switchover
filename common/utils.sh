#!/bin/bash

run_cmd() {
  cmd="$1"
  log "Info" "Running: $cmd"
  eval "$cmd" || fail "Command failed: $cmd"
}

check_file() {
  [ -f "$1" ] || fail "File not found: $1"
}
