//https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?pivots=deployment-language-bicep

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Assign new or existing(to append/maintian exiting access policies)')
@allowed([
  'new'
  'existing'
])
param newOrExisting string

param keyVaultName string

@secure()
param properties object = {}

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
@secure()
param objectId string = ''

@description('Application ID of the client making the request on behalf of a principle')
@secure()
param applicationId string = ''

@description('Specifies the permissions to keys in the vault.  all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = []

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = []

@description('Specifies the permissions to certificates in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param certificatePermissions array = []
param storgePermissions array = []

var accessPoliciesExisting = (newOrExisting == 'existing') ? reference(resourceId('Microsoft.KeyVault/vaults', keyVaultName), '2022-07-01').accessPolicies : []

var identity = !empty(applicationId) ? {
    applicationId: applicationId
  } : {
    objectId: objectId
  }

var accessPolicies = {
  permissions: {
    certificates: certificatePermissions
    keys: keysPermissions
    secrets: secretsPermissions
    storage: storgePermissions
  }
  tenantId: tenantId
}

resource accessPolicyResourceExisting 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = if (newOrExisting == 'existing'){
  name: '${keyVaultName}/add'
  properties: !empty(properties) ? properties :{
    accessPolicies: union(accessPoliciesExisting, [union(identity, accessPolicies)])
  }
}

resource accessPolicyResourceNew 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = if (newOrExisting == 'new'){
  name: '${keyVaultName}/add'
  properties: !empty(properties) ? properties :{
    accessPolicies: union(identity, accessPolicies)
  }
}

output name string =  (newOrExisting == 'new') ? accessPolicyResourceNew.name : accessPolicyResourceExisting.name
