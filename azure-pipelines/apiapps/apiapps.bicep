@description('Location to deploy into')
param location string = az.resourceGroup().location
@description('Application Insights name')
param appInsightsName string
@description('Log Analytics Workspace name')
param logAnalyticsNamespaceName string
@description('Workspace SKU')
param workspaceSKU string
@description('Workspace retention')
param workspaceRetention string
@description('Workspace daily quota')
param workspaceDailyQuota string
@description('Does the Application Insights instance exist')
param aiExists bool = false
@description('List of the API Apps to deploy')
param apiApps array
@description('The url of ACR')
param containerRegistryName string
@description('Managed Identity name')
param identityName string
@description('App Service Plan name')
param appServicePlanName string
@description('App Service Plan SKU')
param sku string
@description('Environment to write in tags')
param env string
@description('Service code for tags')
param serviceCode string
@description('Location value for tags')
param locationTag string

// Check to see if we can find an AppInsights instance
resource existingAppInsights 'Microsoft.Insights/components@2020-02-02' existing = if (aiExists) {
  name: appInsightsName
}
// if there isn't create a new one
var aiTags = {
  Name: appInsightsName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
  Tier: 'ApplicationInsights'
}
var laTags = {
  Name: logAnalyticsNamespaceName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
}
module appInsights '../../../Infra/modules/Microsoft.Insights/components.bicep' = if (!aiExists) {
  name: appInsightsName
  params: {
    applicationInsightsName: appInsightsName
    location: location
    logAnalyticsNamespaceName: logAnalyticsNamespaceName
    workspaceSKU: workspaceSKU
    workspaceRetention: workspaceRetention
    workspaceDailyQuota: workspaceDailyQuota
    aiTags: aiTags
    laTags: laTags
  }
}

var aspTags = {
  Name: appServicePlanName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
}

// Deploy the Apps
module apiApp '../../../Infra/modules/Microsoft.Web/apiapp.bicep' = [for apps in apiApps: {
  name: apps.name
  params: {
    appName: apps.name
    location: location
    dockerImageTag: '${apps.dockerImage}:${apps.dockerTag}'
    containerRegistryName: containerRegistryName
    identityName: identityName
    appServicePlanName: appServicePlanName
    sku: sku
    appInsightsName: appInsightsName
    aspTags: aspTags
    env: env
    serviceCode: serviceCode
    locationTag: locationTag
  }
}]