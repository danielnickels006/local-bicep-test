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
param resourceGroupCore object
param resourceGroupApps object
param monitor object
param function object

module resourceGroupCoreModule '../../modules/resource/resourceGroup.bicep' = {
  name: '${solution}-rgp-core-${environment}'
  scope: subscription(resourceGroupCore.scope.subscriptionId)
  params: {
    location: resourceGroupCore.scope.location
    name: resourceGroupCore.name
    tags: resourceGroupCore.tags
    managedBy: resourceGroupCore.managedBy
    properties: resourceGroupCore.properties
  }
}

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

module logAnalyticsWorkspaceModule '../../modules/monitor/workspace.bicep' = {
  name: '${solution}-law-${environment}'
  scope: resourceGroup(monitor.scope.resourceGroupName)
  params: {
    location: monitor.scope.location
    name: monitor.workspaceName
    retentionInDays: monitor.retentionInDays
    dailyQuotaGb: monitor.dailyQuotaGb
    tags: monitor.tags
  }
  dependsOn: [ resourceGroupCoreModule ]
}

module applicationInsightsModule '../../modules/monitor/applicationInsights.bicep' = {
  name: '${solution}-ain-${environment}'
  scope: resourceGroup(monitor.scope.resourceGroupName)
  params: {
    name: monitor.applicationInsightsName
    location: monitor.scope.location
    workspaceResourceId: logAnalyticsWorkspaceModule.outputs.id
    tags: monitor.tags
  }
  dependsOn: [ logAnalyticsWorkspaceModule ]
}

module functionModule '../../modules/web/function.bicep' = {
  name: '${solution}-fna-${environment}'
  scope: resourceGroup(function.scope.resourceGroupName)
  params: {
    name: function.name
    location: function.scope.location
    functionWorkerRuntime:function.functionWorkerRuntime
    functionsExtensionVersion: function.functionsExtensionVersion
    netFrameworkVersion:function.netFrameworkVersion
    hostNamesDisabled: function.hostNamesDisabled
    use32BitWorkerProcess: function.use32BitWorkerProcess
    applicationInsightsName: function.applicationInsights.name
    applicationInsightsResourceGroup: function.applicationInsights.scope.resourceGroupName
    hostingPlanResourceGroup: function.hostingPlanResourceGroup
    hostingPlanName: function.hostingPlanName
    vnetNetworkResourceGroup: function.vnetNetworkResourceGroup
    vnetName: function.vnetName
    vnetSubnetName: function.vnetSubnetName
    prefixStorageAccountName: function.prefixStorageAccountName
    tags: function.tags
    customAppSettings: function.customAppSettings
  }
  dependsOn: [ resourceGroupAppsModule, applicationInsightsModule ]
}

