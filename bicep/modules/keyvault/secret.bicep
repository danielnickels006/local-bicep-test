//https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/secrets?pivots=deployment-language-bicep

param keyVaultName string

@minLength(1)
@maxLength(127)
param name string
param tags object = {}

@secure()
param properties object = {}

param enabled bool = true

@description('Expiry date in seconds since 1970-01-01T00:00:00Z')
param expiryDate int = -1

@description('Not before date in seconds since 1970-01-01T00:00:00Z.')
param activationDate int = -1

@secure()
param value string

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var attributes = expiryDate > 0 ? {
      enabled: enabled
      exp: expiryDate
} : activationDate > 0 ? {
      enabled: enabled
      nbf: activationDate
} : expiryDate > 0 && activationDate > 0 ? {
      enabled: enabled
      exp: expiryDate
      nbf: activationDate
} : {
  enabled: enabled
}

resource symbolicname 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: name
  tags: tags
  parent: vault
  properties: !empty(properties) ? properties :{
    attributes: attributes
    value: value
  }
}
