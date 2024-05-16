//https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/subscriptions?pivots=deployment-language-bicep

param serviceBusNamespaceName string
param topicName string
param environment string

param properties object = {}
param rules array = []

@minLength(1)
@maxLength(50)
param name string
param deadLetteringOnFilterEvaluationExceptions bool = true
param deadLetteringOnMessageExpiration bool = true
param defaultMessageTimeToLive string = 'P14DT0H0M0S'
param lockDuration string = 'P0DT0H1M0S'
param maxDeliveryCount int = 3

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: topicName
  parent: serviceBusNamespace
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name:  name
  parent: topic
  properties: !empty(properties) ? properties : {
    deadLetteringOnFilterEvaluationExceptions: deadLetteringOnFilterEvaluationExceptions
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    defaultMessageTimeToLive: defaultMessageTimeToLive
    lockDuration: lockDuration
    maxDeliveryCount: maxDeliveryCount
  }
}

module ruleModule './rule.bicep' = [for rule in rules: {
  name: '${rule.name}-${environment}'
  params:{
    serviceBusNamespaceName: serviceBusNamespaceName
    subscriptionName: subscription.name
    topicName: topicName
    name: rule.name
    properties: rule.properties
  }
}]

output name string = subscription.name
