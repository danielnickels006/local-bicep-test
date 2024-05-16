//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service?pivots=deployment-language-bicep

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param name string
param displayName string
param description string
param path string
param serviceUrl string = ''
param subscriptionRequired bool = true
param applicationInsights object = {}
param protocols array =  ['https']

param subscriptionKeyParameterNames array = [
  'Api-Key'
  'subscription-key'
]

resource apimService  'Microsoft.ApiManagement/service@2022-08-01' existing = {
    name: apimNamespaceName
}

resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name: name
  parent: apimService
  properties: {
    displayName: displayName
    description: description    
    subscriptionRequired: subscriptionRequired
    path: path
    protocols: protocols
    isCurrent: true
    subscriptionKeyParameterNames: {
      header: subscriptionKeyParameterNames[0]
      query: subscriptionKeyParameterNames[1]
    }
    serviceUrl: serviceUrl
  }
}

module monitor './diagnostic.bicep' = if(!empty(applicationInsights)){
  name:'${apimNamespaceName}-${api.name}'
  params:{
    apimNamespaceName: apimNamespaceName 
    applicationInsightsName : applicationInsights.name
    applicationInsightsSubscriptionId: applicationInsights.subscriptionId
    applicationInsightsResourceGroup: applicationInsights.resourceGroup
    apiName: name
  }
}

output name string = api.name
