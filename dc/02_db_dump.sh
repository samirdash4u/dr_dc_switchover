#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/*
source ${_commonDir}/*

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to read config file config.sh. Exiting"
fi

mkdir -p $BACKUP_DIR_DC
rm -rf $BACKUP_DIR_DC/*.sql

MYSQL_PWD=$(echo $DB_PASS| base64 -d)
export MYSQL_PWD
dump_db() {
    db=$1
    log "Info" "Taking dump $db from $DC_DB_HOST"
    mysqldump -h $DC_DB_HOST -P $DB_PORT -u $DB_USER --master-data --routines --triggers $db  > $BACKUP_DIR_DC/$TIMESTAMP/${db}.sql
}

export -f dump_db log

# Parallel dump
printf "%s\n" "${DB_LIST[@]}" | xargs -I{} -P 4 bash -c 'dump_db "$@"' _ {}

log "Info" "DB backup completed"
ls -l $BACKUP_DIR_DC
