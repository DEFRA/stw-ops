param serviceBusNamespaceName string
param location string = resourceGroup().location

module serviceBus '../../Infra/modules/Microsoft.Servicebus/servicebus.bicep' = {
  name: serviceBusNamespaceName
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
  }
}

