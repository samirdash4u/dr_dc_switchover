# Format:
# NAME|CONF_PATH|ENDPOINT|ALIAS

CERT_ENTRIES=(
"PRD_CC|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_PRD_CC/conf|api.dc1prdcc.yono2.bank.sbi:6443|k8s-prdcc-api"
"PRD_CC|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_PRD_CC/conf|thanos-querier-openshift-monitoring.apps.dc1prdcc.yono2.bank.sbi:443|k8s-prdcc-thanos"

"DR_CC|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_DR_CC/conf|api.dc3prdcc.yono2.bank.sbi:6443|k8s-drcc-api"
"DR_CC|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_DR_CC/conf|thanos-querier-openshift-monitoring.apps.dc3prdcc.yono2.bank.sbi:443|k8s-drcc-thanos"

"PRD_EMUDRA|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_PRD_EMUDRA/conf|api.dc1prdem.emfsl.bank.sbi:6443|k8s-prdem-api"
"PRD_EMUDRA|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_PRD_EMUDRA/conf|thanos-querier-openshift-monitoring.apps.dc1prdem.emfsl.bank.sbi:443|k8s-prdem-thanos"

"DR_EMUDRA|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_DR_EMUDRA/conf|api.dc3prdem.emfsl.bank.sbi:6443|k8s-drem-api"
"DR_EMUDRA|/HEAL/Appnomic/Appsone_Servcie/dataadapter_kubernetes_DR_EMUDRA/conf|thanos-querier-openshift-monitoring.apps.dc3prdem.emfsl.bank.sbi:443|k8s-drem-thanos"
)

A1HOME_PATH=$(consul kv get service/upgrade/installationpath)
CACERTS_PATH="${A1HOME_PATH}/Appsone_Service/data/cert"
KEYSTORE_PASS=changeit
OVERWRITE=true
