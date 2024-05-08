
@description('The SKU of the App Service Plan')
param sku string
@description('Location of the resource')
param location string = resourceGroup().location // Location for all resources
@description('Name of the App Service Plan')
param appServicePlanName string
@description('Tags to tag the resource with')
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}
output aspId string = appServicePlan.id
