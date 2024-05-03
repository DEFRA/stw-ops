
[CmdletBinding()]
param (
 [Parameter()]
 [string]
 $DEPLOY_TAG = "#{{deployTag}}",
 [Parameter()]
 [string]
 $DOCKER_SECRET = "#{{DEVSTWINFACR1001-ADMIN-PASSWORD}}",
 [Parameter()]
 [string]
 $ACR_REGISTRY_SERVER = "#{{acrServerName}}",
 [Parameter()]
 [string]
 $ACR_REGISTRY_USERNAME = "#{{acrUsername}}",
 [Parameter()]
 [string]
 $APP_NAME = "#{{functionAppName}}",
 [Parameter()]
 [string]
 $RESOURCE_GROUP = "#{{functionAppRG}}"
)

$IMAGE_NAME = "stw-processing-api/stw-processing-api:$DEPLOY_TAG"

az functionapp config container set --image $IMAGE_NAME --registry-password $DOCKER_SECRET --registry-server $ACR_REGISTRY_SERVER --registry-username $ACR_REGISTRY_USERNAME --name $APP_NAME --resource-group $RESOURCE_GROUP
