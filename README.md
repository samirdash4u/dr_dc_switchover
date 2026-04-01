End-to-End Automation Workflow (Production Design)
🧠 Core Design Principles
Idempotent → safe re-run at any stage
State-driven → track phase in Consul KV / file
Pre-check gated → fail fast
Manual approval only where needed (DNS switch, final cutover)
Rollback symmetry → same pipeline supports DR→DC
🏗️ Pipeline Architecture
🔹 Pipeline Stages
[ PRECHECK ] 
     ↓
[ BACKUP ]
     ↓
[ SYNC ]
     ↓
[ VALIDATE_SYNC ]
     ↓
[ APPROVAL_GATE (DNS SWITCH) ]
     ↓
[ SWITCHOVER ]
     ↓
[ POST_VALIDATION ]
     ↓
[ COMPLETE ]
🔹 Stage Breakdown (Execution Logic)
🟢 1. PRECHECK (Fail-fast stage)

Automated checks:

Percona reachable (DC + DR)
Consul cluster healthy
Nomad cluster healthy
OpenSearch health = green/yellow
Disk space check (dump + snapshot)

👉 Output:

{
  "status": "PASS",
  "issues": []
}
🟢 2. BACKUP

Automated actions:

DB dump (DC)
Consul KV export
Nomad job backup
Trigger OpenSearch snapshot

👉 Store in:

/backup/<timestamp>/
🟢 3. SYNC (Core stage)
Copy DB dumps → DR
Take DR pre-backup
Restore DBs in DR
Update DB configs (connection_url)
Sync Consul KV
Sync Nomad jobs
🟢 4. VALIDATE_SYNC

Automated checks:

DB row counts / checksum
Consul KV diff = 0
Nomad jobs diff = 0
Percona replication status
OpenSearch indices match

🟡 5. APPROVAL GATE
Manual:
DNS switch
👉 Pipeline waits:
CONFIRM_DNS_SWITCH=true
🔴 6. SWITCHOVER

Automated:
DC
Stop HAProxy
Stop OTEL
Stop CA agents

DR
Start HAProxy
Start OTEL
Start CA agents

🟢 7. POST VALIDATION
KPI ingestion
Connector data flow
RabbitMQ queue health
Grafana dashboards
API checks

🔁 8. ROLLBACK SUPPORT
Same pipeline with:
--direction DR_TO_DC

🔷 Orchestration Options
Pure Bash Orchestrator
Lightweight
Works with Nomad infra

🔷 State Tracking (Critical)
consul kv put switchover/status PRECHECK_DONE
consul kv put switchover/status SYNC_DONE
