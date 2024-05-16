//https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/extensions?pivots=deployment-language-bicep

param location string = resourceGroup().location
param name string
param tags object




resource symbolicname 'Microsoft.Sql/servers/databases/extensions@2022-05-01-preview' = {
  name: 'string'
  parent: resourceSymbolicName
  properties: {
    administratorLogin: 'string'
    administratorLoginPassword: 'string'
    operationMode: 'Import'
    storageKey: 'string'
    storageKeyType: 'StorageAccessKey'
    storageUri: '...../database.bacpac' //https://learn.microsoft.com/en-us/azure/azure-sql/database/database-export?view=azuresql
  }
}
