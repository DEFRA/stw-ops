@description('The name of the KeyVault to create')
param vaultName string

@description('The location of the resource')
param vaultLocation string

@description('Object containing the values to add to the tags of the resouce')
param tags object

@description('The tenant ID for the subscription')
var tenantId = subscription().tenantId

resource myVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: vaultName
  location: vaultLocation
  tags: {
    Environment: tags.environment
    Tier: tags.tier
    ServiceType: tags.serviceType
    ServiceName: tags.serviceName
    Location: vaultLocation
    Name: vaultName
    ServiceCode: tags.serviceCode
  }
  properties: {
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenantId
    accessPolicies:[]
  }
}
