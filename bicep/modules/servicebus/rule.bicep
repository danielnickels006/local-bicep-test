//https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/subscriptions/rules?pivots=deployment-language-bicep

param serviceBusNamespaceName string
param topicName string
param subscriptionName string
param properties object = {}

@allowed([
  'SqlFilter'
])
param filterType string = 'SqlFilter'
param name string = '$Default'
param sqlExpression string = '1=1'
param requiresPreprocessing bool = false

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: topicName
  parent: serviceBusNamespace
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' existing = {
  name: subscriptionName
  parent: topic
}

resource rule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2022-10-01-preview' = {
  name: name
  parent: subscription
  properties: !empty(properties) ? properties : {
      filterType: filterType
      sqlFilter: {
        sqlExpression: sqlExpression
        requiresPreprocessing: requiresPreprocessing
      }
    }
}
