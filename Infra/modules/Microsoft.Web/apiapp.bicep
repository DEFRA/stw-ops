@description('Name of the app to deploy')
param appName string
@description('Location of the resource')
param location string = resourceGroup().location
@description('The docker image name and tag')
param dockerImageTag string
@description('The URL for the ACR')
param containerRegistryName string
@description('Managed Identity name')
param identityName string
@description('App Service Plan name')
param appServicePlanName string
@description('App Service Plan SKU')
param sku string
@description('Name of Application Insights')
param appInsightsName string
@description('Tags to tag the App Service Plan with')
param aspTags object
@description('The env we are deploying to')
param env string
@description('The service code to add to tags')
param serviceCode string
@description('The location tag for the resource')
param locationTag string
@description('Name of the KeyVault')
param keyVaultName string
@description('Resource group of the KeyVault')
param keyVaultRgName string
@description('Subnet id')
param subnetId string
@description('appSettings id')
param appSettings object[]
@description('The tenant ID for the subscription')
var tenantId = subscription().tenantId

// Create the app service plan
module appServicePlan 'asp.bicep' = {
  name: appServicePlanName
  params: { 
    appServicePlanName: appServicePlanName
    location: location
    sku: sku
    tags: aspTags
  }
}
var aspId = appServicePlan.outputs.aspId

// Get a reference to the Managed Identity
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: identityName
}
output uamiId string = uami.id

// Get a reference to the Application Insights instance
resource aiName 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

var dockerImage = '${containerRegistryName}/${dockerImageTag}'

var apiTags = {
  Name: appName
  Location: locationTag
  Environment: env
  ServiceCode: serviceCode
}

// Create the App
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  tags: apiTags
  kind: 'app,linux,container'
  properties: {
    httpsOnly: true
    keyVaultReferenceIdentity: uami.id
    serverFarmId: aspId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImage}'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: uami.properties.clientId
      minTlsVersion: '1.2'
      healthCheckPath: '/admin/health'
      ftpsState: 'Disabled'
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: aiName.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: aiName.properties.ConnectionString
        }
        {
          name: 'ServiceBusConnectionString'
          value: '123'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetId
    swiftSupported: true
  }
}


// create the access policy
module accessPolicy '../Microsoft.KeyVault/accesspolicy.bicep' = {
  name: 'myAccessPolicy'
  scope: resourceGroup(keyVaultRgName)
  params: { 
    keyVaultName: keyVaultName
    tenantId: tenantId
    managedIdId: uami.properties.principalId
  }
}
