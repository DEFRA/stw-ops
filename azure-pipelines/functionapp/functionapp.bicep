@description('Location for all resources except Application Insights.')
param location string = resourceGroup().location
@description('The language worker runtime to load in the function app.')
param runtime string = 'dotnet-isolated'
@description('The name of the function app that you wish to create.')
param functionAppName string
param hostingPlanName string
param storageAccountName string
param ServiceBusConnectionString string
param ServiceBusQueueName string
@description('Name of the managed identity to assign to the slot.')
param managedIdentityName string
param env string
param aiExists bool = false
param appInsightsName string
@description('Location value for tags')
param locationTag string
@description('Log Analytics Workspace name')
param logAnalyticsNamespaceName string
@description('Service code for tags')
param serviceCode string
@description('Workspace retention')
param workspaceRetention string
@description('Workspace daily quota')
param workspaceDailyQuota string
@description('Workspace SKU')
param workspaceSKU string
@description('The docker image name and tag')
param dockerImage string
@description('Vnet name')
param vnetName string
@description('Subnet name')
param subnetName string
@description('Vnet resource group')
param vnetRg string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
name: storageAccountName
location: location
sku: {
  name: 'Standard_ZRS'
 }
 kind: 'StorageV2'
}

var functionWorkerRuntime = runtime
var azureWebJobsStorageConnection = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
var aspTags = {
  Name: hostingPlanName
  Location: location
  Environment: env
  ServiceCode: 'STW'
  Tier: 'ASP'
}

var FappTags = {
  Name: functionAppName
  Location: location
  Environment: env
  ServiceCode: 'STW'
  Tier: 'ASP'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  kind: 'Linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
  reserved: true
  }
  tags: aspTags
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
}

resource existingAppInsights 'Microsoft.Insights/components@2020-02-02' existing = if (aiExists) {
  name: appInsightsName
}
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

// set the value of instrumentation key based on which of the above ran
var InstrumentationKey = appInsights.outputs.InstrumentationKey

// Get the subnet reference
resource mySubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup('${vnetRg}') // look in a specified resorce group, otherwise it fails
}
resource function 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags: FappTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    keyVaultReferenceIdentity: uami.id
    siteConfig: {
      alwaysOn: true
      vnetRouteAllEnabled: false // needed to force traffic through the vnet
      linuxFxVersion: 'DOCKER|${dockerImage}'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: uami.properties.clientId
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azureWebJobsStorageConnection
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
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
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${InstrumentationKey}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: InstrumentationKey
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
  }
  dependsOn: [
  ]
}

output functionAppUrl string = function.properties.defaultHostName

resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: function
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: mySubnet.id
    swiftSupported: true
  }
}
