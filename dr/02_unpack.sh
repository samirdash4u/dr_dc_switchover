#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}/../common"
_confDir="${_baseDir}/../config"

for file in $(find ${_confDir} -type f -name "*.sh"); do
    source "$file"
done
for file in $(find ${_commonDir} -type f -name "*.sh"); do
    source "$file"
done

mkdir -p ${BACKUP_DIR_DR}

BUNDLE="switchover_bundle_$(date +%F).tar.gz"

log "Info" "Unpackaging artifacts"
tar -zxvf "$BUNDLE" -C ${BACKUP_DIR_DR}
log "Info" "Unpacking done"
