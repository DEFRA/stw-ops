targetScope='subscription'

@description('The name of the resource group to be created')
param resourceGroupName string

@description('The location of the resource')
param resourceGroupLocation string

@description('Object containing the values to add to the tags of the resouce')
param tags object

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: {
    Environment: tags.environment
    Tier: tags.tier
    ServiceType: tags.serviceType
    ServiceName: tags.serviceName
    Location: resourceGroupLocation
    Name: resourceGroupName
    ServiceCode: tags.serviceCode
  }
}
