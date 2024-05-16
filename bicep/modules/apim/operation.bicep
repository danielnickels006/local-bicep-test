//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations?pivots=deployment-language-bicep

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param properties object = {}
param apiName string
param name string
param displayName string

@allowed([
  'GET'
  'POST'
  'PATCH'
  'PUT'
  'DELETE'
  'OPTIONS'
])
param method string
param urlTemplate string
param requestQueryParameters array = []
param templateParameters array = []
param requestHeaders array = []
param requestRepresentations array = []
param responses array = []

resource apimService 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
  name: apiName
  parent: apimService
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  name: name
  parent: api
  properties: !empty(properties) ? properties : {
    displayName: displayName
    method: method
    urlTemplate: urlTemplate
    request: {
      queryParameters: requestQueryParameters
      headers: requestHeaders
      representations: requestRepresentations
    }
    responses: responses
    templateParameters: templateParameters
  }
}

output name string = operation.name
