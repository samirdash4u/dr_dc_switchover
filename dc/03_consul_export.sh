#!/bin/bash
set -e
source ../common/logger.sh

OUT_DIR=$WORK_DIR/consul
mkdir -p "$OUT_DIR"

log "Info" "Exporting Consul KV"
consul kv export > "$OUT_DIR/kv.json"
