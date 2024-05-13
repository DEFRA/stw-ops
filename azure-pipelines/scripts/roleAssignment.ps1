$acr_resource_id = (az acr show --name DEVSTWINFACR1001 --query id --output tsv)
$identity_principal_id = (az identity show --resource-group DEVSTWINFRG1001 --name DEVSTWINFMI1001 --query principalId --output tsv)


Write-Host "identity_principal_id id is $identity_principal_id"
Write-Host "acr_resource_id id is $acr_resource_id"

az role assignment create --role "AcrPull" --assignee-object-id $identity_principal_id --scope $acr_resource_id --assignee-principal-type ServicePrincipal