//https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers//databases?pivots=deployment-language-bicep

param location string = resourceGroup().location
param sqlServerName string
param name string
param sku object = {
  name: 'Basic'
  tier: 'Basic'
  capacity: 5
}

param maxSizeBytes int = 2147483648
param properties object = {}
param tags object

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: name
  location: location
  sku: sku
  tags: tags
  properties: !empty(properties) ? properties : {
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    isLedgerOn: false
    maxSizeBytes: maxSizeBytes
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    zoneRedundant: false
  }
}


output connectionString string = 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=${name};Persist Security Info=False;User ID=@userId;Password=@password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
