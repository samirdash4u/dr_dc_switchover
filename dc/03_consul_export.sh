#!/bin/bash
set -e
_baseDir=$(dirname(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/config.sh
source ${_confDir}/logger.sh
source ${_confDir}/utils.sh

OUT_DIR=${BACKUP_DIR_DC}/consul
mkdir -p "$OUT_DIR"

log "Info" "Exporting Consul KV on dc"
consul kv get -recurse > "$OUT_DIR/kvlistdc.txt"
