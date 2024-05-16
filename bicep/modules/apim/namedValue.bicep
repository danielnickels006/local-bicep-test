//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/namedvalues?pivots=deployment-language-bicep
@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param name string
param displayName string
param secret bool = true
param tags array

@secure()
param keyVaultSecretIdentifier string = ''
@secure()
param value string = ''

param properties object = {}

resource apimService  'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

var isKeyVaultSecret = !empty(keyVaultSecretIdentifier) ? {
      displayName: displayName
      keyVault: {
        secretIdentifier: keyVaultSecretIdentifier
      }
      secret: secret
      tags: tags
} : {
      displayName: displayName
      secret: secret
      tags: tags
      value: value
}

resource namedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: name
  parent: apimService
    properties: !empty(properties) ? properties : isKeyVaultSecret
  }
