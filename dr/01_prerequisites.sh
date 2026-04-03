#!/bin/bash
set -euo pipefail

source ../config/config.sh
source ../common/logger.sh
source ../common/utils.sh

STATUS=0
export NOMAD_CLI_SHOW_HINTS=false

# ---------------------------------------
# 1. CONSUL CLUSTER CHECK
# ---------------------------------------
check_consul() {
    log "Info" "Checking Consul cluster..."

    if ! consul members >/tmp/consul_members.out 2>&1; then
	  fail_check "Consul not reachable"
	  return
    fi

    if grep -q "alive" /tmp/consul_members.out; then
	  pass "Consul members are alive"
    else
	  fail_check "No alive Consul members"
    fi

    LEADER=$(consul operator raft list-peers | grep leader || true)
    if [ -z "$LEADER" ]; then
	  fail_check "No Consul leader found"
    else
	  pass "Consul leader present"
    fi
}

# ---------------------------------------
# 2. NOMAD CLUSTER CHECK
# ---------------------------------------
check_nomad() {
    log "Info" "Checking Nomad cluster..."

    if ! nomad server members >/tmp/nomad_members.out 2>&1; then
	  fail_check "Nomad not reachable"
	  return
    fi

    if grep -q "left" /tmp/nomad_members.out; then
	  fail_check "Few nomad members are in left state"
    else
	  pass "Nomad members are alive"
    fi
}

# ---------------------------------------
# 3. MYSQL CHECK
# ---------------------------------------

check_mysql() {
    MYSQL_PWD=$(echo $DB_PASS | base64 -d)
    export MYSQL_PWD
    log "Info" "Checking MySQL connectivity..."

    if mysql -h $DR_DB_HOST -P $DB_PORT -u $DB_USER -e "SELECT 1;" >/dev/null 2>&1; then
	  pass "MySQL is reachable"
    else
	  fail_check "MySQL connection failed"
    fi
}

# ---------------------------------------
# 4. OPENSEARCH CHECK
# ---------------------------------------
check_opensearch() {
    log "Info" "Checking OpenSearch..."
    RESPONSE=$(curl -sk -u $OPENSEARCH_USER:$OPENSEARCH_PASS "$DR_OPENSEARCH_URL/_cluster/health")
    STATUS_OS=$(echo "$RESPONSE" | jq -r '.status')

    if [[ "$STATUS_OS" == "green" || "$STATUS_OS" == "yellow" ]]; then
	  pass "OpenSearch healthy ($STATUS_OS)"
    else
	  fail_check "OpenSearch unhealthy ($STATUS_OS)"
    fi
}

# ---------------------------------------
# 5. DISK SPACE CHECK
# ---------------------------------------
check_disk() {
    log "Info" "Checking disk space..."

    for path in "${DISK_PATHS[@]}"; do
	  USAGE=$(df -P "$path" | awk 'NR==2 {print $5}' | tr -d '%')
	  FREE=$((100 - USAGE))

	  log "Info" "Disk $path → Used: $USAGE%, Free: $FREE%"

	  if [ "$FREE" -lt "$MIN_DISK_FREE_PERCENT" ]; then
		fail_check "Low disk space on $path"
	  else
		pass "Disk OK on $path"
	  fi
    done
}

# ---------------------------------------
# 6. NOMAD JOB VALIDATION (KEYWORDS)
# ---------------------------------------
check_nomad_jobs() {
    log "Info" "Checking Nomad jobs from keywords..."
    [ -f "$DR_JOB_KEYWORDS_FILE" ] || fail_check "Keyword file missing"
    nomad job status  > /tmp/nomad_jobs.txt 2>/dev/null

    while read -r keyword; do
	  [ -z "$keyword" ] && continue
	  grep -qw "$keyword" /tmp/nomad_jobs.txt
	  if [ $? -ne 0 ]; then
		fail_check "No jobs found for keyword: $keyword"
		continue
	  fi
	  RUNNING=$(grep -c "$keyword.*running" /tmp/nomad_jobs.txt)
	  if [ "$RUNNING" -gt 0 ]; then
		  pass "Job running: $keyword"
	  else
		  fail_check "Job NOT running: $keyword"
	  fi
    done < "$DR_JOB_KEYWORDS_FILE"
}

# ---------------------------------------
# EXECUTION
# ---------------------------------------

log "Info" "Starting prerequisite checks..."

check_consul
check_nomad
check_mysql
check_opensearch
check_disk
check_nomad_jobs

echo "--------------------------------------"

if [ "$STATUS" -eq 0 ]; then
    log "Info" "ALL CHECKS PASSED ✅"
    exit 0
else
    log "Info" "SOME CHECKS FAILED ❌"
    exit 1
fi
