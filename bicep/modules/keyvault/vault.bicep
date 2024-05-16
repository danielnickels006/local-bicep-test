//https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep

param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('Assign new or existing(to append/maintian exiting access policies)')
@allowed([
  'new'
  'existing'
])
param newOrExisting string

param name string
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'
param tags object

@secure()
param properties object = {}

param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false
param enableSoftDelete bool = true

@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

param enableRbacAuthorization bool = false
param vaultUri string
param networkAcls object = {}
param provisioningState string = 'Succeeded'
param publicNetworkAccess string = 'Enabled'
param accessPolicies array

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' =
  if (newOrExisting == 'new') {
    name: name
    location: location
    tags: tags
    properties: !empty(properties)
      ? properties
      : {
          sku: {
            family: 'A'
            name: skuName
          }
          enabledForDeployment: enabledForDeployment
          enabledForDiskEncryption: enabledForDiskEncryption
          enabledForTemplateDeployment: enabledForTemplateDeployment
          enableRbacAuthorization: enableRbacAuthorization
          accessPolicies: accessPolicies
          enableSoftDelete: enableSoftDelete
          networkAcls: networkAcls
          provisioningState: provisioningState
          publicNetworkAccess: publicNetworkAccess
          softDeleteRetentionInDays: softDeleteRetentionInDays
          tenantId: tenantId
          vaultUri: vaultUri
        }
  }

module accessPoliciesModule 'accessPolicy.bicep' = [
  for (policy, i) in accessPolicies: if (newOrExisting == 'existing') {
    name: '${i}-${name}-acp'
    params: {
      keyVaultName: name
      newOrExisting: newOrExisting
      objectId: policy.objectId
      applicationId: policy.applicationId
      keysPermissions: policy.permissions.keys
      secretsPermissions: policy.permissions.secrets
      storgePermissions: policy.permissions.storage
      certificatePermissions: policy.permissions.certificates
    }
  }
]

output name string = name
