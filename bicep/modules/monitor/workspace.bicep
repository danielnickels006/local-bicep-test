//https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep

param location string = resourceGroup().location
param name string
param tags object = {}
@allowed([
  30
  60
  90
  120
  180
  270
  365
])
param retentionInDays int = 90
param skuName string = 'pergb2018'

param dailyQuotaGb int = 1

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    sku: {
      name: skuName
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
  }
}

output id string = workspace.id
