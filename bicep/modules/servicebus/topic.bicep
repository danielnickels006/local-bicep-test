//https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics?pivots=deployment-language-bicep
param environment string
param serviceBusNamespaceName string

param name string
param defaultMessageTimeToLive string = 'P14DT0H0M0S'

param subscriptions array = []

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: name
  parent: serviceBusNamespace
  properties: {
    defaultMessageTimeToLive: defaultMessageTimeToLive
  }
}

module subscriptionModule './subscription.bicep' = [for subscription in subscriptions: {
  name: '${subscription.name}-${environment}'
  params:{
    environment: environment
    serviceBusNamespaceName: serviceBusNamespaceName
    topicName: name
    name: subscription.name
    properties: subscription.properties
    rules: subscription.rules
  }
}]

output name string = topic.name
