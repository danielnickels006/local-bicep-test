//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep
//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep
//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites/functions/keys?pivots=deployment-language-bicep

param location string = resourceGroup().location

@description('The name of the function app that you wish to create.')
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

@allowed([
  'dotnet'
  'dotnet-isolated'
])
param functionWorkerRuntime string 
param functionsExtensionVersion string
param netFrameworkVersion string

param tags object = {}
@description('Custom configuration Application Settings')
param customAppSettings array = []

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Can contain only lowercase letters and numbers')
@maxLength(11)
param prefixStorageAccountName string
param storageAccountName string = '${prefixStorageAccountName}${uniqueString(resourceGroup().id)}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

//https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/existing-resource#different-scope
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

var defaultAppSettings =   [{
                      name: 'AzureWebJobsStorage'
                      value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
                    }
                    {
                      name: 'FUNCTIONS_EXTENSION_VERSION'
                      value: functionsExtensionVersion
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
                      name: 'FUNCTIONS_WORKER_RUNTIME'
                      value: functionWorkerRuntime
                    }]

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'functionapp,windows'
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
  }
}

output principalId string = functionApp.identity.principalId
output defaultHostKey string = listkeys('${functionApp.id}/host/default', '2016-08-01').functionKeys.default
