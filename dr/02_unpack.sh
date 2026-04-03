#!/bin/bash
set -e

_baseDir=$(dirname(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/config.sh
source ${_confDir}/logger.sh
source ${_confDir}/utils.sh
mkdir -p ${BACKUP_DIR_DR}

BUNDLE="switchover_bundle_$(date +%F).tar.gz"

log "Info" "Unpackaging artifacts"
tar -zxvf "$BUNDLE" -C ${BACKUP_DIR_DR}
log "Info" "Unpacking done"
