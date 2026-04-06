#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/*
source ${_commonDir}/*

OUT_DIR=${BACKUP_DIR_DC}/consul
mkdir -p "$OUT_DIR"

log "Info" "Exporting Consul KV on dc"
consul kv get -recurse > "$OUT_DIR/kvlistdc.txt"
