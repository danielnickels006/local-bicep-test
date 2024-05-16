//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep
//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep
//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites/functions/keys?pivots=deployment-language-bicep

param location string = resourceGroup().location

@description('The name of the webApp that you wish to create.')
param name string
param hostingPlanName string
param hostingPlanResourceGroup string
param applicationInsightsName string
param applicationInsightsResourceGroup string = resourceGroup().location

param vnetName string
param vnetNetworkResourceGroup string
param vnetSubnetName string
param vnetRouteAll bool = false
param hostNamesDisabled bool = false
param use32BitWorkerProcess bool = false

param netFrameworkVersion string
param clientAffinityEnabled bool = false
param scmSiteAlsoStopped bool = false

param tags object = {}
@description('Custom configuration Application Settings')
param customAppSettings array = []

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(hostingPlanResourceGroup)
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing =  {
  name : vnetSubnetName
  parent: vnet
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsResourceGroup)
}

var defaultAppSettings =   [
                    {
                      name: 'XDT_MicrosoftApplicationInsights_Mode'
                      value: 'Recommended'
                    }
                    {
                      name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
                      value: applicationInsights.properties.ConnectionString
                    }
                    {
                      name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                      value: applicationInsights.properties.InstrumentationKey
                    }
                    {
                      name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
                      value: '~3'
                    }]

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    serverFarmId: hostingPlan.id
    virtualNetworkSubnetId: subnet.id
    siteConfig: {
      appSettings: union(defaultAppSettings, customAppSettings)
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: netFrameworkVersion
      vnetRouteAllEnabled: vnetRouteAll
      vnetName: vnetName
      alwaysOn: true
      use32BitWorkerProcess: use32BitWorkerProcess
    }
    httpsOnly: true
    hostNamesDisabled:hostNamesDisabled
    clientAffinityEnabled: clientAffinityEnabled
    scmSiteAlsoStopped: scmSiteAlsoStopped
  }
}

output principalId string = webApp.identity.principalId
