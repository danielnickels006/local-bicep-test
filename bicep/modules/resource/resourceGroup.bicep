//https://learn.microsoft.com/en-us/azure/templates/microsoft.resources/2022-09-01/resourcegroups?pivots=deployment-language-bicep#resourcegroups
targetScope = 'subscription'

param location string
param name string
param tags object
param managedBy string = ''
param properties object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
  tags: tags
  managedBy: managedBy
  properties: properties
}

output name string = resourceGroup.name
output location string = resourceGroup.location
