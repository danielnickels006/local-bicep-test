//https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components?pivots=deployment-language-bicep

param location string = resourceGroup().location
param name string
param tags object = {}
param properties object = {}
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

@allowed([
  'web'
  'other'
  'ios' 
  'store' 
  'java' 
  'phone'
])
param kind string = 'web'

@allowed([
  'web'
  'other'
])
param applicationType string = 'web'
param workspaceResourceId string

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

resource newAin 'Microsoft.Insights/components@2020-02-02' =  if (newOrExisting == 'new') {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: !empty(properties) ? properties : {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    RetentionInDays: retentionInDays
  }
}

resource existingAin 'Microsoft.Insights/components@2020-02-02' existing = if (newOrExisting == 'existing') {
  name: name
}

output name string =  ((newOrExisting == 'new') ? newAin.name : existingAin.name)
