#!/bin/bash
set -euo pipefail

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}../common"
_confDir="${_baseDir}../config"
source ${_confDir}/*
source ${_commonDir}/*

_a1homePath=$(consul kv get service/upgrade/installationpath)
_nomadJobPath="$(_a1homePath)/nomadFile"

OUT_DIR=${RESTORE_DIR_DR}/nomad
mkdir -p "$OUT_DIR"

if [ -d "${_nomadJobPath}" ]; then
    pass "Nomad jobs directory found taking nomad version backup"
else
    fail_check "Nomad jobs directory not found"
    return 1
fi

grep -i image ${_nomadJobPath}/*.nomad | awk -F'=' '{print $2}' | tr -d ' "' | sort -u > $OUT_DIR/dockerimagelistdr.txt

FILE1=$OUT_DIR/dockerimagelistdc.txt
FILE2=$OUT_DIR/dockerimagelistdr.txt

[ -f "$FILE1" ] || { echo "$FILE1 not found"; exit 1; }
[ -f "$FILE2" ] || { echo "$FILE2 not found"; exit 1; }

TMP1=$(mktemp)
TMP2=$(mktemp)

# Normalize → extract image + version
# format: image:version
awk -F'/' '{print $2}' "$FILE1" | sort > "$TMP1"
awk -F'/' '{print $2}' "$FILE2" | sort > "$TMP2"

logger "Info" "Image Version Differences (File1 vs File2)"

join -j 1 -o 1.1,1.2,2.2 \
  <(awk -F':' '{print $1,$2}' "$TMP1" | sort) \
  <(awk -F':' '{print $1,$2}' "$TMP2" | sort) \
| while read image v1 v2; do
    if [ "$v1" != "$v2" ]; then
        logger "Info" "$image → DC:$v1 | DR:$v2"
    fi
done

rm -f "$TMP1" "$TMP2"
