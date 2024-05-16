//https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep&pivots=deployment-language-bicep

param enabled bool = true
param actionGroupName string
param tags object = {}
param emailReceivers array = []

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: 'Global'
  tags: tags
  properties: {
    enabled: enabled
    groupShortName: actionGroupName
    emailReceivers: emailReceivers
  }
}

output name string = actionGroup.name
