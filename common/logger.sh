#!/bin/bash

LOG_DIR=${LOG_DIR:-./logs}
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/$(basename $0)_$(date +%F).log"


log() {
    local _level="$1"
    shift
    local _message="$@"
    echo "$(date +"%F-%H-%M")[${_level}]: ${_message}";
}

fail() {
  log "ERROR" "$1"
  exit 1
}
