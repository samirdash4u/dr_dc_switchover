#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}/common"
_confDir="${_baseDir}/config"
source ${_confDir}/*
source ${_commonDir}/*

TMP_CERT="/tmp/cert_$$.crt"

alias_exists() {
    log "Info" "Checking if alias $alias is already present in cacerts"
    local keystore=$1
    local alias=$2
    keytool -list -keystore "$keystore" -storepass "$KEYSTORE_PASS" -alias "$alias" >/dev/null 2>&1
}

fetch_cert() {
    local endpoint=$1
    log "Info" "Fetching cert from $endpoint"
    echo | openssl s_client -connect "$endpoint" 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$TMP_CERT"

    if [ ! -s "$TMP_CERT" ]; then
	  fail "Failed to fetch cert from $endpoint"
    fi
}

import_cert() {
    local keystore=$1
    local alias=$2

    log "Debug" "Importing cert → alias=$alias"

    keytool -import -trustcacerts \
	  -keystore "$keystore" \
	  -storepass "$KEYSTORE_PASS" \
	  -noprompt \
	  -alias "$alias" \
	  -file "$TMP_CERT"
}

delete_alias() {
    local keystore=$1
    local alias=$2

    log "Debug" "Deleting existing alias → $alias"

    keytool -delete \
	  -keystore "$keystore" \
	  -storepass "$KEYSTORE_PASS" \
	  -alias "$alias" \
	  >/dev/null 2>&1 || fail "Failed to delete alias: $alias"
}

process_entry() {
    IFS='|' read -r name path endpoint alias <<< "$1"
    log "Info" "Processing [$name] → $endpoint"
    cd "$path" || fail "Directory not found: $path"
    KEYSTORE="${CACERTS_PATH}/cacerts"

    if alias_exists "$KEYSTORE" "$alias"; then
	  if [ "$OVERWRITE" == "true" ]; then
		log "Alias exists and overwrite enabled → $alias"
		delete_alias "$KEYSTORE" "$alias"
	  else
		log "Alias already exists → skipping ($alias)"
		return
	  fi
    fi

    fetch_cert "$endpoint"
    import_cert "$KEYSTORE" "$alias"

    log "Info" "Completed impporting for → $alias"
}

# ---------------------------------------
log "Info" "Checking if cacerts is present in ${CACERTS_PATH}"
if [ -f "${CACERTS_PATH}/cacerts" ]; then
    log "Error" "cacerts file not found at ${CACERTS_PATH}"
    exit 1
fi
log "Info" "Starting certificate import process..."

for entry in "${CERT_ENTRIES[@]}"; do
    process_entry "$entry"
done

rm -f "$TMP_CERT"

log "Info" "All certificate imports completed"
