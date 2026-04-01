#!/bin/bash
set -euo pipefail

_baseDir=$(dirname(readlink -f $0))
_confDir="${_baseDir}/config"
source ${_confDir}/config.sh

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to read config file ${_confDir}/config.sh. Exiting"
fi

mkdir -p $BACKUP_DIR_DR
rm -rf $BACKUP_DIR_DR/*.sql

mkdir -p $RESTORE_DIR_DR

log() {
    local _level="$1"
    shift
    local _message="$@"
    echo "$(date +"%F-%H-%M")[${_level}]: ${_message}";
}

MYSQL_PWD=$(echo $DB_PASS| base64 -d)
export MYSQL_PWD

update_entry() {
    db=$1
    log "Info" "Updating mysql entry in $db "
    mysql -h $DR_DB_HOST -P $DB_PORT -u $DB_USER  $db -e "update adapter_chain_repository set connection_url ='jdbc:mysql://${DR_DB_HOST}:${DB_PORT}/${db}?useUnicode=yes&characterEncoding=UTF-8&useSSL=false' where id in (1,2,3,4); update adapter_chain_repository set connection_url ='jdbc:mysql://${DR_DB_HOST}:${DB_PORT}/appsone?useUnicode=yes&characterEncoding=UTF-8&useSSL=false' where id=5;"
    if [ $? -ne 0 ]; then
	  log "Error" "Failed to update entries for database ${db}. Please check manually"
    fi
}

export -f update_entry log

# Restore
for db in "${DB_LIST[@]}"; do
  update_entry $db
done

log "Info" "Updating connector table entires completed"

