WORKER_ID=16

# Default endpoint (fallback)
DEFAULT_ENDPOINT="10.177.72.10:9598"

# DB list
CONNECTOR_DBS=(
dataadapter_kubernetes_DR_CC
dataadapter_kubernetes_DR_EMUDRA
dataadapter_kubernetes_DR_INB
dataadapter_kubernetes_DR_MB
dataadapter_kubernetes_PRD_CC
dataadapter_kubernetes_PRD_EMUDRA
)

# Optional overrides per DB
declare -A DB_ENDPOINT_OVERRIDE
DB_ENDPOINT_OVERRIDE[dataadapter_kubernetes_DR_EMUDRA]="10.177.72.11:9598"
DB_ENDPOINT_OVERRIDE[dataadapter_kubernetes_PRD_CC]="10.177.72.12:9598"

