//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/tags?pivots=deployment-language-bicep

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param apiName string
param name string
param displayName string

resource apimService 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
  name: apiName
  parent: apimService
}

resource tag 'Microsoft.ApiManagement/service/tags@2022-08-01' = {
  name: name
  parent: apimService
  properties:{
    displayName: displayName
  }
}

resource tagApi 'Microsoft.ApiManagement/service/apis/tags@2019-12-01' = {
  name: name
  parent: api
}
