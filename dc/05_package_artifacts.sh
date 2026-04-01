#!/bin/bash
set -e
source ../common/logger.sh

BUNDLE="switchover_bundle_$(date +%F_%H-%M).tar.gz"

log "Packaging artifacts"
tar -czf "$BUNDLE" -C "$WORK_DIR" .

log "Bundle created: $BUNDLE"
