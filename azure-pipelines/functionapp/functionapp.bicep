@description('Location for all resources except Application Insights.')
param location string = resourceGroup().location
@description('The language worker runtime to load in the function app.')
param runtime string = 'dotnet-isolated'
@description('The name of the function app that you wish to create.')
param functionAppName string
param hostingPlanName string
param storageAccountName string
param ServiceBusConnectionString string
@description('Name of the managed identity to assign to the slot.')
param managedIdentityName string
param env string

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
    siteConfig: {
      alwaysOn: true
      vnetRouteAllEnabled: false // needed to force traffic through the vnet
      linuxFxVersion: 'DOTNETCORE|8.0'
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
      ]
    }
  }
  dependsOn: [
  ]
}

output functionAppUrl string = function.properties.defaultHostName