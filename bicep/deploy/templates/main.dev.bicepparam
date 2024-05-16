using './main.bicep'

param environment = 'dev'
param solution = 'bicep'

param resourceGroupCore = {
  scope: {
    subscriptionId: '722ac943-eac8-4820-a689-00956825b76f'
    location: 'australiasoutheast'
  }
  name: '${environment}-${solution}-core-rgp'
  tags: {
    function: solution
    environment: environment
    teams: 'ecom'
    costcentre: 'it'
    billto: 'tgg'
  }
  managedBy: ''
  properties: {}
}

param resourceGroupApps = {
  scope: {
    subscriptionId: '722ac943-eac8-4820-a689-00956825b76f'
    location: 'australiasoutheast'
  }
  name: '${environment}-${solution}-apps-rgp'
  tags: {
    function: solution
    environment: environment
    teams: 'ecom'
    costcentre: 'it'
    billto: 'tgg'
  }
  managedBy: ''
  properties: {}
}

param monitor = {
  scope: {
    resourceGroupName: resourceGroupCore.name
    location: resourceGroupCore.scope.location
  }
  workspaceName: '${environment}-${solution}-law'
  applicationInsightsName: '${environment}-${solution}-core-ain'
  retentionInDays: 90
  dailyQuotaGb: 1
  tags: resourceGroupCore.tags
}

param function = {
  scope: {
    resourceGroupName: resourceGroupApps.name
    location: resourceGroupApps.scope.location
  }
  name: '${environment}-${solution}-fna'
  functionWorkerRuntime:'dotnet-isolated'
  functionsExtensionVersion: '~4'
  netFrameworkVersion:'v8.0'
  hostNamesDisabled: false
  use32BitWorkerProcess: false
  hostingPlanResourceGroup: 'npd-partner-asp-rgp'
  hostingPlanName: 'npd-win-core-asp'
  vnetNetworkResourceGroup: 'npd-network-rgp'
  vnetName: 'npd-mel-vnw01'
  vnetSubnetName: 'App'
  prefixStorageAccountName: '${environment}${solution}'
  tags: resourceGroupApps.tags
  applicationInsights: {
    name: monitor.applicationInsightsName
    scope: {
      resourceGroupName: monitor.scope.resourceGroupName
    }
  }
  customAppSettings: [
    {
      name: 'WEBSITE_TIME_ZONE'
      value: 'AUS Eastern Standard Time'
    }
  ]
}
