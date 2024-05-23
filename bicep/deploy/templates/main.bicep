targetScope = 'subscription'

@allowed(
  [
    'dev'
    'tst'
    'uat'
    'prd'
  ]
)
param environment string
param solution string
param resourceGroupApps object

module resourceGroupAppsModule '../../modules/resource/resourceGroup.bicep' = {
  name: '${solution}-rgp-apps-${environment}'
  scope: subscription(resourceGroupApps.scope.subscriptionId)
  params: {
    location: resourceGroupApps.scope.location
    name: resourceGroupApps.name
    tags: resourceGroupApps.tags
    managedBy: resourceGroupApps.managedBy
    properties: resourceGroupApps.properties
  }
}
