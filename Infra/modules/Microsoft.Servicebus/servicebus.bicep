@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

param location string

param tags object

param processingApiQueueName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
  tags: tags
}


resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: processingApiQueueName
  parent: serviceBusNamespace
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P14D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    forwardDeadLetteredMessagesTo: 'string'
    lockDuration: 'PT1M'
    maxDeliveryCount: 10
    maxMessageSizeInKilobytes: 256
    maxSizeInMegabytes: 2048
    requiresDuplicateDetection: false
    requiresSession: false
    status: 'Active'
  }
}
