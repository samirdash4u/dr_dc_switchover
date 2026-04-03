#!/bin/bash
set -e

_baseDir=$(dirname(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/config.sh
source ${_confDir}/logger.sh
source ${_confDir}/utils.sh
BUNDLE="switchover_bundle_$(date +%F).tar.gz"

log "Info" "Packaging artifacts"
tar -czf "$BUNDLE" ${BACKUP_DIR_DC}/*

log "Info" "Bundle created: $BUNDLE"
