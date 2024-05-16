//https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/policies?pivots=deployment-language-bicep

param properties object = {}

@allowed([
  'npd-mel-apipfm-api'
  'prd-mel-apipfm-api'
])
param apimNamespaceName string

param apiName string
param operationName string
param enableCorrelationId bool = false
var name = 'policy'

@secure()
param value string

@allowed([
  'rawxml'
  'rawxml-link'
  'xml'
  'xml-link'
])
param format string

resource apimService 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimNamespaceName
}

resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
  name: apiName
  parent: apimService
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' existing = {
  name: operationName
  parent: api
}

var contract = !empty(format) ? {
  value: value
  format: format
}:{ 
  value: format
} 

resource policies 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = {
  name: name
  parent: operation
  properties: !empty(properties) ? properties : contract
}

resource policyCorrelationId 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = if(enableCorrelationId) {
  name: name
  parent: api
  properties: {
    value: '<policies>\r\n<inbound>\r\n<base />\r\n<set-variable name="x-correlation-id" value="@(context.Request.Headers.GetValueOrDefault(&quot;x-correlation-id&quot;, Guid.NewGuid().ToString()))" />\r\n<set-header name="X-Correlation-ID" exists-action="override"> <value>@((string)context.Variables["x-correlation-id"])</value></set-header>\r\n<trace source="All operations policy" severity="information"> \r\n <message>@(String.Format("{0} | {1}", context.Api.Name, context.Operation.Name))</message> \r\n <metadata name="x-correlation-id" value="@((string)context.Variables[&quot;x-correlation-id&quot;])" /> \r\n</trace> \r\n</inbound> \r\n<backend> \r\n<base /> \r\n</backend> \r\n<outbound> \r\n<base /> \r\n<set-header name="X-Correlation-ID" exists-action="override"> <value>@((string)context.Variables["x-correlation-id"])</value></set-header>\r\n</outbound>\r\n<on-error>\r\n<base />\r\n</on-error>\r\n</policies>'
    format: 'xml'
  }
}
