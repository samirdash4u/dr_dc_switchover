#!/bin/bash
set -euo pipefail

_baseDir=$(dirname(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/config.sh
source ${_confDir}/logger.sh
source ${_confDir}/utils.sh

OUT_DIR=${RESTORE_DIR_DR}/consul
if [ -f "${OUT_DIR}/kvlistdc.txt" ]; then
    pass "Consul backup file from dc found"
else
    fail_check "Consul backup file from dc not found"
fi

log "Info" "Exporting Consul KV on DR"
consul kv get -recurse > "$OUT_DIR/kvlistdr.txt"

FILE1="${OUT_DIR}/kvlistdc.txt"
FILE2="${OUT_DIR}/kvlistdr.txt"

TMP1=$(mktemp)
TMP2=$(mktemp)

# Extract keys (before :)
cut -d':' -f1 "$FILE1" | sort -u > "$TMP1"
cut -d':' -f1 "$FILE2" | sort -u > "$TMP2"

log "Info" "Keys present in $FILE1 but missing in $FILE2:"
log "Debug" "=======KeyList========"
comm -23 "$TMP1" "$TMP2" | tee -a "$LOG_FILE"
log "Debug" "=======KeyList========"

rm -f "$TMP1" "$TMP2"
