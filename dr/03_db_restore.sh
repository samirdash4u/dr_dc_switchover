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

mkdir -p $BACKUP_DIR_DR
rm -rf $BACKUP_DIR_DR/*.sql
mkdir -p $RESTORE_DIR_DR

MYSQL_PWD=$(echo $DB_PASS| base64 -d)
export MYSQL_PWD

restore_db() {
    db=$1
    log "Info" "Restoring $db to DR"
    if [ -f "$RESTORE_DIR_DR/${db}.sql" ]; then
	  mysql -h $DR_DB_HOST -P $DB_PORT -u $DB_USER  $db < $RESTORE_DIR_DR/${db}.sql
    else
	  log "Error" "Mysql dump file for ${db} not found in $RESTORE_DIR_DR folder"
    fi
}

backup_dr_db() {
    db=$1
    log "Info" "Taking DR backup for $db on host $DR_DB_HOST"
    mysqldump -h $DR_DB_HOST -P $DB_PORT -u $DB_USER $db > $BACKUP_DIR_DR/${db}_DR_backup.sql
    log "Info" "Drop the database $db and create again for importing newer dumps from DC"
    mysql -h $DR_DB_HOST -P $DB_PORT -u $DB_USER  -e "drop database $db; create database $db;"
    if [ $? -ne 0 ]; then
	  log "Error" "Dropping and recreating database failed for $db. Please check manually"
    fi
}

export -f restore_db backup_dr_db log

# Restore
for db in "${DB_LIST[@]}"; do
  backup_dr_db $db
  restore_db $db
done

log "Info" "DB restore completed"
