//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service?pivots=deployment-language-bicep

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param environment string
param name string
param productName string

@description('Required for \'new\' only')
param displayName string = ''
@description('Required for \'new\' only')
param apiDescription string = ''
@description('Required for \'new\' only')
param path string = ''
@description('Required for \'new\' only')
param serviceUrl string = ''
param tags array = []
param operations array = []
param policies array = []
param namedValues array = []
param applicationInsights object = {}

param subscriptionKeyParameterNames array = [
  'Api-Key'
  'subscription-key'
]

@allowed([
  'new'
  'existing'
])
param newOrExisting string

@description('Creates \'All operations\' inbound/outbound policy, setting X-Correlation-ID header and tracing')
param enableCorrelationId bool = false

resource apimService  'Microsoft.ApiManagement/service@2022-08-01' existing = {
    name: apimNamespaceName
}

module apiNew './api.bicep' =  if (newOrExisting == 'new') {
  name: '${name}-${environment}'
  params:{
    name: name
    displayName: displayName
    description: apiDescription    
    subscriptionRequired: true
    path: path
    subscriptionKeyParameterNames: subscriptionKeyParameterNames
    serviceUrl: serviceUrl
    apimNamespaceName: apimNamespaceName
    applicationInsights: applicationInsights 
  }
}

resource apiExisting 'Microsoft.ApiManagement/service/apis@2022-08-01' existing =  if (newOrExisting == 'existing') {
  name: name
  parent: apimService
}

resource product 'Microsoft.ApiManagement/service/products@2022-08-01' existing = {
  name: productName
  parent: apimService
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = if (newOrExisting == 'new') {
  name: name
  parent: product
  dependsOn: [apiNew]
}

module tag './tag.bicep' = [for tag in tags: {
  name: '${tag.name}-${environment}'
  params:{
     apimNamespaceName: apimNamespaceName
     apiName: ((newOrExisting == 'new') ? apiNew.outputs.name : apiExisting.name)
     name: tag.name
     displayName: tag.name
  }
}]

module namedValueModule './namedValue.bicep' = [for namedValue in namedValues: {
  name: '${namedValue.name}-${environment}'
  params: {
      name: namedValue.name
      apimNamespaceName: apimNamespaceName
      displayName: namedValue.displayName
      secret: namedValue.secret
      tags: namedValue.tags
      value: namedValue.value
      keyVaultSecretIdentifier:namedValue.keyVaultSecretIdentifier
    }
  }]

module operationModule './operation.bicep' = [for op in operations: {
  name: '${op.name}-${environment}'
  params: {
      apimNamespaceName: apimNamespaceName
      apiName: ((newOrExisting == 'new') ? apiNew.outputs.name : apiExisting.name)
      name: op.name
      displayName: op.displayName
      method: op.method
      urlTemplate: op.urlTemplate
      templateParameters: op.templateParameters
      requestQueryParameters: op.requestQueryParameters
      responses: op.responses
    }
  }]

var policyCount = length(policies)
module policyModule './policy.bicep' = [for i in range(0, policyCount) : {
  name: 'policy-${i}-${policies[i].operationName}'
  params: {
    apimNamespaceName: apimNamespaceName
    apiName: ((newOrExisting == 'new') ? apiNew.outputs.name : apiExisting.name)
    operationName: policies[i].operationName
    value: policies[i].value
    format: policies[i].format
    enableCorrelationId: enableCorrelationId
  }
  dependsOn: operationModule
}]

resource identity 'Microsoft.ManagedIdentity/identities@2023-01-31' existing = {
  scope: apimService
  name: 'default'
}

output name string = ((newOrExisting == 'new') ? apiNew.outputs.name : apiExisting.name)
output principalId string = identity.properties.principalId
