@description('Name of the log analytics workspace')
param logAnalyticsNamespaceName string
@description('Location of the resource')
param location string
@description('The SKU of the workspace to create')
param workspaceSKU string
@description('The workspace retention')
param workspaceRetention string
@description('Daily quota for workspace')
param workspaceDailyQuota string
@description('Tags for the log analytics workspace')
param laTags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsNamespaceName
  location: location
  tags: laTags
  properties: {
    sku: {
      name: workspaceSKU
    }
    retentionInDays: int(workspaceRetention)
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    workspaceCapping: {
      dailyQuotaGb: int(workspaceDailyQuota)
    }
  }
}
output workspaceID string = logAnalyticsWorkspace.id
