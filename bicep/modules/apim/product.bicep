//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products?pivots=deployment-language-bicep

//# Note: Currently developers dont create products so will only assign a product to an exisitng api

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param name string

resource apimService  'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

resource api  'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
name: name
parent: apimService
}

resource product 'Microsoft.ApiManagement/service/products@2022-08-01' existing = {
  name: name
  parent: apimService
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = {
  name: api.name
  parent: product
}
