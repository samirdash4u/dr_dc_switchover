#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/*
source ${_commonDir}/*

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to read config file ${_confDir}/config.sh. Exiting"
fi

mkdir -p $BACKUP_DIR_DR
rm -rf $BACKUP_DIR_DR/*.sql
mkdir -p $RESTORE_DIR_DR

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

update_kpi_endpoint_all_dbs() {
  source ./config/env.sh
  source ./common/logger.sh

  for DB_NAME in "${CONNECTOR_DBS[@]}"; do

    # Pick endpoint (override > default)
    NEW_ENDPOINT="${DB_ENDPOINT_OVERRIDE[$DB_NAME]:-$DEFAULT_ENDPOINT}"

    log "Info" "Processing DB: $DB_NAME"
    log "Info" "Using endpoint: $NEW_ENDPOINT"

    # Validate endpoint format
    echo "$NEW_ENDPOINT" | grep -E '^[^:]+:[0-9]+$' || fail "Invalid endpoint format for $DB_NAME"

    MYSQL_PWD=$(echo $DB_PASS | base64 -d)
    export MYSQL_PWD
    log "Debug" "Executing below query"
    log "Debug" "mysql -N -s -h $DR_DB_HOST -P $DB_PORT -u $DB_USER -e \"SELECT id, value FROM ${DB_NAME}.worker_parameters WHERE worker_id=$WORKER_ID AND name='data-receiver.kpi.endpoint';\""

    RESULTS=$(mysql -N -s -h $DR_DB_HOST -P $DB_PORT -u $DB_USER -e "SELECT id, value FROM ${DB_NAME}.worker_parameters WHERE worker_id=$WORKER_ID AND name='data-receiver.kpi.endpoint';")

    if [ -z "$RESULTS" ]; then
	  log "Info" "No matching rows found in $DB_NAME."
	  continue
    fi

    echo "$RESULTS" | while read -r id value; do
	  # Extract protocol
	  proto=$(echo "$value" | awk -F:// '{print $1}')

	  # Extract path
	  path=$(echo "$value" | cut -d'/' -f4-)

	  new_value="${proto}://${NEW_ENDPOINT}/${path}"

	  if [ "$value" == "$new_value" ]; then
		log "Debug" "No change needed (DB=$DB_NAME, id=$id)"
		continue
	  fi

	  log "Info" "Updating DB=$DB_NAME id=$id"
	  log "Info" "OLD: $value -> NEW: $new_value"

        mysql -h $DR_DB_HOST -P $DB_PORT -u $DB_USER -e "UPDATE ${DB_NAME}.worker_parameters SET value='${new_value}' WHERE id=$id;"
    done
  done
  log "Info" "All worker paramater DB updates completed"
}

export -f update_entry log update_kpi_endpoint_all_dbs

# Restore
for db in "${DB_LIST[@]}"; do
  update_entry $db
done
log "Info" "Updating connector table entires completed"

log "Info" "Updating worker parameter entires"

update_kpi_endpoint_all_dbs

log "Info" "All DB updates completed"
