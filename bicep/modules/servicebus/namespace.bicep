//https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces?pivots=deployment-language-bicep

param location string = resourceGroup().location

@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string
param tags object

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  tags: tags
}

output name string = serviceBusNamespace.name
