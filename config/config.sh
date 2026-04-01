# config.env

# In case of switching from DC to DR keep the values unchanged
# While switching from DR to DC interchange the values for DC_DB_HOST and DR_DB_HOST
## For DC to DR  [ Leave this block commented in case of DR to DC Switch ] 
DC_DB_HOST=10.188.40.182
DR_DB_HOST=10.177.72.182

## For DC to DR  [ Leave this block commented in case of DC to DR Switch ] 
#DC_DB_HOST=10.188.40.182
#DR_DB_HOST=10.177.72.182

DB_PORT=3307
DB_USER="dbadmin"
DB_PASS="cm9vdEAxMjM="

## Append list of databases for to take backup
DB_LIST=(
appsone
appsonekeycloak
appsone_mle
dataadapter_kubernetes_DR_CC
dataadapter_kubernetes_DR_EMUDRA
dataadapter_kubernetes_DR_INB
dataadapter_kubernetes_DR_MB
dataadapter_kubernetes_PRD_CC
dataadapter_kubernetes_PRD_CCS
dataadapter_kubernetes_PRD_CC_Elasticsearch
dataadapter_kubernetes_PRD_EMUDRA
dataadapter_kubernetes_PRD_EMUDRA_Elasticsearch
dataadapter_kubernetes_PRD_FOS
dataadapter_kubernetes_PRD_INB
dataadapter_kubernetes_PRD_MB
)

## Configure backup dir on DC where mysql dump will be takend and stored
BACKUP_DIR_DC="/tmp/BACKUP_DUMPS_FOR_Activity"

## Configure Restore dir where files from DC will be copied via winscp or scp or using similar utility
RESTORE_DIR_DR="/tmp/DC_DUMPS_LATEST"

## Configure backup dir where mysql dump from dr will be taken and stored before restoring dump from DC
BACKUP_DIR_DR="/tmp/Before_Activity_dump"
