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
@description('DockerImage')
param dockerImage string
@description('dockerTag')
param dockerTag string
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
@description('The service bus connection string')
param ServiceBusConnectionString string
@description('The service bus queue name')
param ServiceBusQueueName string
@description('Stub Api database connection string')
param StubApiDatabaseConnectionString string
@description('appName')
param name string
@description('The Keyvault name')
param keyVaultName string
@description('Resource group of the KeyVault')
param keyVaultRgName string
@description('Vnet name')
param vnetName string
@description('Subnet name')
param subnetName string
@description('Vnet resource group')
param vnetRg string

// Check to see if we can find an AppInsights instance
resource existingAppInsights 'Microsoft.Insights/components@2020-02-02' existing = if (aiExists) {
  name: appInsightsName
}
// if there isn't create a new one
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

var aiTags = {
  Name: appInsightsName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
  Tier: 'ApplicationInsights'
}

// Get the subnet reference
resource mySubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup('${vnetRg}') // look in a specified resorce group, otherwise it fails
}

var laTags = {
  Name: logAnalyticsNamespaceName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
}


var aspTags = {
  Name: appServicePlanName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
}

var appSettings = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: existingAppInsights.properties.InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: existingAppInsights.properties.ConnectionString
  }
  {
    name: 'ServiceBusConnectionString'
    value: ServiceBusConnectionString
  }
  {
    name: 'ServiceBusQueueName'
    value: ServiceBusQueueName
  }
  {
    name: 'ConnectionStrings__StubApiDatabase'
    value: StubApiDatabaseConnectionString
  }
]

// Deploy the Apps
module apiApp '../../../Infra/modules/Microsoft.Web/apiapp.bicep' = {
  name: name
  params: {
    appName: name
    location: location
    dockerImageTag: '${dockerImage}:${dockerTag}'
    containerRegistryName: containerRegistryName
    identityName: identityName
    appServicePlanName: appServicePlanName
    sku: sku
    appInsightsName: appInsightsName
    aspTags: aspTags
    env: env
    serviceCode: serviceCode
    locationTag: locationTag
    appSettings: appSettings
    keyVaultName: keyVaultName
    keyVaultRgName: keyVaultRgName
    subnetId: mySubnet.id
  }
}
