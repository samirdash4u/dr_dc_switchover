#!/bin/bash

_baseDir=$(dirname(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/config.sh
source ${_confDir}/logger.sh
source ${_confDir}/utils.sh
_a1homePath=$(consul kv get service/upgrade/installationpath)
_nomadJobPath="$(_a1homePath)/nomadFile"

OUT_DIR=${BACKUP_DIR_DC}/nomad
mkdir -p "$OUT_DIR"

if [ -d "${_nomadJobPath}" ]; then
    pass "Nomad jobs directory found taking nomad version backup"
else
    fail_check "Nomad jobs directory not found"
    return 1
fi

grep -i image ${_nomadJobPath}/*.nomad | awk -F'=' '{print $2}' | tr -d ' "' | sort -u > $OUT_DIR/dockerimagelistdc.txt
