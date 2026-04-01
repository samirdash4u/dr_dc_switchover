#!/bin/bash
set -e
source ../common/logger.sh

OUT_DIR=$WORK_DIR/nomad/jobs
mkdir -p "$OUT_DIR"

log "Info" "Fetching job list"
nomad job status -json | jq -r '.[].ID' > $WORK_DIR/metadata/nomad_list.txt

while read job; do
  log "Info" "Exporting job: $job"
  nomad job inspect -json "$job" > "$OUT_DIR/$job.json"
done < $WORK_DIR/metadata/nomad_list.txt
