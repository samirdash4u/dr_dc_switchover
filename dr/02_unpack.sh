#!/bin/bash
set -e
source ../config/env.sh
source ../common/logger.sh

DB_DIR=$WORK_DIR/db

log "Info" "Validating checksums"
cd $DB_DIR
md5sum -c $WORK_DIR/metadata/db_checksums.txt || fail "Checksum mismatch"
