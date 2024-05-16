//https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/queues?pivots=deployment-language-bicep

param serviceBusNamespaceName string
param name string
param properties object = {}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

param lockDuration string = 'PT30S'
param defaultMessageTimeToLive string = 'P14D'
param deadLetteringOnMessageExpiration bool = true
param maxDeliveryCount int = 10

@allowed([
  1024
  2048
  3072
  4096
  5120
])
param maxSizeInMegabytes int = 1024

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: name
  properties: !empty(properties) ? properties : {
    lockDuration: lockDuration
    maxSizeInMegabytes: maxSizeInMegabytes
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: defaultMessageTimeToLive
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    maxDeliveryCount: maxDeliveryCount
  }
}
