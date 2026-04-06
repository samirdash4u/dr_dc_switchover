# DC–DR Switchover Automation

This repository automates the **Data Center (DC) → Disaster Recovery (DR)** switchover process for Appsone/HEAL platform.
The automation replaces manual SOP steps with **repeatable, idempotent, and safe scripts**.

## 🔷 Key Features

* ✅ Fully automated **DB, Consul, Nomad sync**
* ✅ Artifact-based execution (supports **isolated DC & DR environments**)
* ✅ Config-driven (no hardcoding)
* ✅ Idempotent operations (safe re-run)
* ✅ Pre-check validation (infra + services)
* ✅ Certificate management automation
* ✅ Endpoint update automation for connector DBs


## 🔷 Architecture Overview
Since DC and DR environments are **not directly connected**, this solution uses:
DC → Generate Artifacts → Transfer → DR → Apply

### Artifact Bundle Includes:
* DB dumps
* Consul KV export
* Nomad job definitions

## 🔷 Execution Flow
### 🔹 Step 1: Run in DC

This will:
* Dump all DBs
* Export Consul KV
* Export Nomad job image versions
* Create bundle

Output:
switchover_bundle_<timestamp>.tar.gz

### 🔹 Step 2: Transfer Bundle
Move bundle to DR environment (manual/secure transfer).

### 🔹 Step 3: Run in DR
This will:
* Restore DBs
* Provide a detail of missing Consul Keys
* List nomad job image version mismatch


## 🔷 Pre-check Validation
Run:

./prerequisites.sh

Checks:

* Consul cluster health
* Nomad cluster health
* MySQL connectivity
* OpenSearch health
* Disk space
* Required Nomad jobs running

## 🔷 Certificate Automation
./scripts/import_certs.sh

Features:

* Fetch certs via openssl
* Import into keystore
* Skip existing aliases
* Overwrite mode supported

## 🔷 Connector Endpoint Update
Features:

* Updates all connector DBs
* Supports per-DB override
* Preserves protocol & path
* Idempotent

## 🔷 Known Constraints
* No direct DC ↔ DR connectivity
* Requires manual bundle transfer
* DNS switch is external/manual

## Folder structure
.
├── common
│   ├── importcert.sh
│   ├── logger.sh
│   └── utils.sh
├── config
│   ├── certs.sh
│   ├── config.sh
│   ├── dcnomadjoblist.txt
│   ├── drnomadjoblist.txt
│   └── workerentry.sh
├── dc
│   ├── 01_prerequisites.sh
│   ├── 02_db_dump.sh
│   ├── 03_consul_export.sh
│   ├── 04_nomad_export.sh
│   └── 05_package_artifacts.sh
├── dr
│   ├── 01_prerequisites.sh
│   ├── 02_unpack.sh
│   ├── 03_db_restore.sh
│   ├── 04_update_entry.sh
│   ├── 05_consul_match.sh
│   └── 06_nomad_match.sh
└── README.md

## 🔷 Configuration [ Must be same for for both dc and dr env. Configure on dc and copy on dr ]
1. certs.sh
   Configure as show below
   NAME|CONF_PATH|ENDPOINT|ALIAS
   Configure Overwrite = true if you wish to remove older alias and import again
   Configure Overwrite = false to skip existing alias

2. config.sh
   Configure database parameters, names of database to take back and backup/restore paths on host

3. dcnomadjoblist.txt
   List of nomad jobs expected to be running on dc env

4. drnomadjoblist.txt
   List of nomad jobs expected to be running on dr env

5. workerentry.sh
   Provide the list of databases where data receiver end point in worker parameters table will be updated
   Also provide the endpoint as IP:PORT 
   If same endpoint has to be updated in all tables then configure DEFAULT_END_POINT
   else configure DB wise endpoints 
## Execution prerequisities [ Run prerequisites on bothe dc and dr env to check readiness ]
   Configure the above parameters and run the  dc/01_prerequisites.sh on dc env and dr/01_prerequisites.sh on dr env.

## Execution [ First on dc and then on dr ]
   Execute the scripts for dc env in the numerical error
   Once execution is over there will be a tar file containing all the db dumps
   Copy the tar file in the dr env and run the scripts from dr folder in numerical order

## 🔷 Author
Samir Dash
