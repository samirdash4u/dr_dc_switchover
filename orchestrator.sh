#!/bin/bash
set -euo pipefail

# -------------------------------
# Defaults
# -------------------------------
MODE=""
DRY_RUN=false
BUNDLE=""

_baseDir=$(dirname $(readlink -f $0))
_commonDir="${_baseDir}/common"
_confDir="${_baseDir}/config"
source ${_confDir}/*.sh
source ${_commonDir}/*.sh

fail() {
  log "Error" "$*"
  exit 1
}

# -------------------------------
# Command runner (dry-run aware)
# -------------------------------
run_step() {
  local desc="$1"
  local cmd="$2"

  if [ "$DRY_RUN" == "true" ]; then
    echo "[DRY-RUN] $desc"
    echo "          $cmd"
  else
    log "Info" "$desc"
    eval "$cmd"
  fi
}

# -------------------------------
# Usage
# -------------------------------
usage() {
  cat <<EOF
Usage:
  $0 --dc [--dry-run]
  $0 --dr --bundle <file> [--dry-run]

Options:
  --dc             Run DC phase (dump + export + package)
  --dr             Run DR phase (restore + import + validate)
  --bundle <file>  Required for DR mode
  --dry-run        Show actions without executing

Examples:
  $0 --dc
  $0 --dc --dry-run
  $0 --dr --bundle switchover_bundle.tar.gz
  $0 --dr --bundle switchover_bundle.tar.gz --dry-run
EOF
}

# -------------------------------
# Argument Parsing
# -------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dc)
      MODE="dc"
      shift
      ;;
    --dr)
      MODE="dr"
      shift
      ;;
    --bundle)
      BUNDLE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# -------------------------------
# Validation
# -------------------------------
[ -z "$MODE" ] && { usage; exit 1; }

log "Info" "Mode      : $MODE"
log "Info" "Dry Run   : $DRY_RUN"
[ -n "$BUNDLE" ] && log "Info" "Bundle    : $BUNDLE"

# -------------------------------
# DC FLOW
# -------------------------------
run_dc() {

  log "Info" "Starting DC execution..."

  run_step "Pre-check validation" \
    "$_baseDir/dc/01_prerequisites.sh"
  run_step "DB dump" \
    "$_baseDir/dc/02_db_dump.sh"

  run_step "Consul export" \
    "$_baseDir/dc/03_consul_export.sh"

  run_step "Nomad export" \
    "$_baseDir/dc/04_nomad_export.sh"

  run_step "Package artifacts" \
    "$_baseDir/dc/05_package_artifacts.sh"

  log "Info" "DC execution completed"
}

# -------------------------------
# DR FLOW
# -------------------------------
run_dr() {

  log "Info" "Starting DR execution..."

  run_step "Pre-check validation" \
    "$_baseDir/dr/01_prerequisites.sh"

  run_step "Unpack bundle" \
    "$_baseDir/dr/02_unpack.sh $BUNDLE"

  run_step "DB restore" \
    "$_baseDir/dr/03_db_restore.sh"

  run_step "Update db entries" \
    "$_baseDir/dr/04_update_entry.sh"

  run_step "Consul keys validation" \
    "$_baseDir/dr/05_consul_match.sh"

  run_step "Certificate import" \
    "$_baseDir/import_certs.sh"

  run_step "Nomad job image version validation" \
    "$_baseDir/dr/06_nomad_match.sh"

  log "Info" "DR execution completed"
}

# -------------------------------
# Execute
# -------------------------------
case "$MODE" in
  dc)
    run_dc
    ;;
  dr)
    run_dr
    ;;
  *)
    fail "Invalid mode"
    ;;
esac

log "Info" "Orchestration finished"
