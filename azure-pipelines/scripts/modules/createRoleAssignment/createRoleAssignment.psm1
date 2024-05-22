function createRoleAssignment ($CONTAINER_REGISTRY, $RESOURCE_GROUP, $MANAGED_IDENTITY_NAME, $ROLE) {

    $acr_resource_id = (az acr show --name $CONTAINER_REGISTRY --query id --output tsv)
    $identity_principal_id = (az identity show --resource-group $RESOURCE_GROUP --name $MANAGED_IDENTITY_NAME --query principalId --output tsv)

    Write-Host "identity_principal_id id is $identity_principal_id"
    Write-Host "acr_resource_id id is $acr_resource_id"

    az role assignment create --role $ROLE --assignee-object-id $identity_principal_id --scope $acr_resource_id --assignee-principal-type ServicePrincipal
}

Export-ModuleMember -Function createRoleAssignment