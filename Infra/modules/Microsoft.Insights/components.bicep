@description('Name of the Application Insights instance')
param applicationInsightsName string
@description('Location of the resources')
param location string
@description('Log Analytics Workspace name')
param logAnalyticsNamespaceName string
@description('Workspace SKU')
param workspaceSKU string
@description('Workspace retention')
param workspaceRetention string
@description('Workspace daily quota')
param workspaceDailyQuota string
@description('Tags for Application Insights')
param aiTags object
@description('Tags for Workspace')
param laTags object

// Create the workspace
module workSpace '../Microsoft.OperationalInsights/workspace.bicep' = {
  name: logAnalyticsNamespaceName
  params: {
    logAnalyticsNamespaceName: logAnalyticsNamespaceName
    location: location
    workspaceSKU: workspaceSKU
    workspaceRetention: workspaceRetention
    workspaceDailyQuota: workspaceDailyQuota
    laTags: laTags
  }
}
var workspaceResourceId = workSpace.outputs.workspaceID

// Create the Application Insights instance
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: aiTags
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: workspaceResourceId
  }
}
output InstrumentationKey string = applicationInsights.properties.InstrumentationKey
