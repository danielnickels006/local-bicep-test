//https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep

param location string = resourceGroup().location
param applicationInsightsName string
param actionGroupName string

param name string
param  displayName string = ''
param tags object = {}
param description string = ''

@allowed([
  0
  1
  2
  3
  4
]
)
param severity int
param enabled bool = true
param query string
@allowed([
  'PT5M'
  'PT10M'
  'PT15M'
  'PT30M'
  'PT45M'
  'PT1H'
  'PT2H'
  'PT3H'
  'PT4H'
  'PT5H'
  'PT6H'
  'PD1'
  'PD2'
])
param evaluationFrequency string = 'PT5M'

@allowed([
  'PT5M'
  'PT10M'
  'PT15M'
  'PT30M'
  'PT45M'
  'PT1H'
  'PT2H'
  'PT3H'
  'PT4H'
  'PT5H'
  'PT6H'
  'PD1'
])
param windowSize string = 'PT5M'
param timeAggregation string = 'Count'

@allowed([
  'GreaterThan'
  'GreaterThanOrEqualTo'
  'LessThan'
  'LessThanOrEqualTo'
  'EqualTo'
])
param operator string = 'GreaterThan'
param threshold int = 0
param numberOfEvaluationPeriods int = 1
param minFailingPeriodsToAlert int = 1

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' existing = {
  name: actionGroupName
}

resource  scheduledQuery  'Microsoft.Insights/scheduledQueryRules@2022-08-01-preview' = {
  name: name
  location: location
  tags: tags
  properties:{
    actions: {
      actionGroups: [actionGroup.id]
    }
    description: description
    displayName: displayName
    enabled: enabled
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    severity: severity
    scopes: [
      applicationInsights.id
    ]
    criteria: {
      allOf: [
        {
          query: query
          timeAggregation: timeAggregation
          operator: operator
          threshold: threshold
          failingPeriods: {
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
          }
        }
      ]
    }
  }
}
