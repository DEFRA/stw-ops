
[CmdletBinding()]
param (
 [Parameter()]
 [string]
 $DEPLOY_TAG,
 [Parameter()]
 [string]
 $DOCKER_SECRET = "#{{DEVSTWINFACR1001-ADMIN-PASSWORD}}",
 [Parameter()]
 [string]
 $ACR_REGISTRY_SERVER,
 [Parameter()]
 [string]
 $ACR_REGISTRY_USERNAME,
 [Parameter()]
 [string]
 $APP_NAME,
 [Parameter()]
 [string]
 $RESOURCE_GROUP,
 [Parameter()]
 [string]
 $KEYVAULT_NAME,
 [Parameter()]
 [string]
 $CONTAINER_REGISTRY
)

Write-Host "Applying version - $DEPLOY_TAG"
$IMAGE_NAME = "$CONTAINER_REGISTRY.azurecr.io/stw/stw-processing-api:$DEPLOY_TAG"

az functionapp config container set --image $IMAGE_NAME --registry-password $DOCKER_SECRET --registry-server $ACR_REGISTRY_SERVER --registry-username $ACR_REGISTRY_USERNAME --name $APP_NAME --resource-group $RESOURCE_GROUP
