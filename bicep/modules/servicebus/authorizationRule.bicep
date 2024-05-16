// https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/authorizationrules?pivots=deployment-language-bicep
param serviceBusNamespaceName string
param name string = '$Default'
@allowed(
  [
    'Send'
    'Listen'
    'Manage'
  ])
param rights array 

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource serviceBusAuthorizationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-10-01-preview' = {
  name: name
  parent: serviceBusNamespace
  properties: {
    rights: [for right in rights: right]
  }
}

output id string = serviceBusAuthorizationRule.id
output connectionString string = serviceBusAuthorizationRule.listKeys().primaryConnectionString
output apiVersion string = serviceBusAuthorizationRule.apiVersion
