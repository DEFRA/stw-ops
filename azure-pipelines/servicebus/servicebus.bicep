param serviceBusNamespaceName string
param location string = resourceGroup().location
param env string
param processingApiQueueName string

var servicebusTags = {
  Name: serviceBusNamespaceName
  Location: location
  Environment: env
  ServiceCode: 'STW'
  Tier: 'ASP'
}

module serviceBus '../../Infra/modules/Microsoft.Servicebus/servicebus.bicep' = {
  name: serviceBusNamespaceName
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
    tags: servicebusTags
    processingApiQueueName: processingApiQueueName
  }
}
