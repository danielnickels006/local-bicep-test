//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2022-08-01/service/loggers?pivots=deployment-language-bicep
@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param applicationInsightsName string
param applicationInsightsSubscriptionId string
param applicationInsightsResourceGroup string
param apiName string

resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
  name: apiName
  parent: apim
}

resource ain 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsSubscriptionId, applicationInsightsResourceGroup)
}

resource logger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = {
  name: '${apimNamespaceName}/${ain.name}'
  properties: {
    loggerType: 'applicationInsights'
    description: ain.name
    resourceId: ain.id
    credentials: {
      instrumentationKey: ain.properties.InstrumentationKey
    }
  }
}

resource diagnostic 'Microsoft.ApiManagement/service/apis/diagnostics@2022-08-01' = {
  name: 'applicationinsights'
  parent: api
  properties: {
    alwaysLog: 'allErrors'
    loggerId: logger.id
    logClientIp: true
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    operationNameFormat: 'Url'
  }
}
