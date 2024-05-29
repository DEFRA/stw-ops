@description('Name of the KeyVault')
param keyVaultName string
@description('The tenant ID for the subscription')
param tenantId string
param managedIdId string

resource Keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing =  {
  name: keyVaultName
}

// Ensure that our Managed Identity has secret permission on the KV
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  parent: Keyvault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: managedIdId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
  }
}
