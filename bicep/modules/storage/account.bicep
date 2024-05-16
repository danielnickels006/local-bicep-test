//https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep

param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
@description('Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.')
param storageAccountName string

@description('Storage account type.')
@allowed([
    'Standard_LRS'
])
param storageAccountSkuName string

@allowed([
    'StorageV2'    
])
param kind string = 'StorageV2'

param tags object

@allowed([
    'Cool'
    'Hot'
    'Premium'
])
param accessTier string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
    name: storageAccountName
    location: location
    tags: tags
    sku: {
        name: storageAccountSkuName
    }
    kind: kind
    properties: {
        accessTier: accessTier
        encryption: {
            keySource: 'Microsoft.Storage'
            services: {
              blob: {
                enabled: true
              }
              file: {
                enabled: true
              }
            }
          }
          supportsHttpsTrafficOnly: true
          allowBlobPublicAccess: false
          minimumTlsVersion: 'TLS1_2'
    }
}

@description('The ID of the created or existing Storage Account. Use this ID to reference the Storage Account in other Azure resource deployments.')
output id string = storageAccount.id
