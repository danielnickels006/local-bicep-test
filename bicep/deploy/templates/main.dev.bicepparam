using './main.bicep'

param environment = 'dev'
param solution = 'bicep'

param resourceGroupApps = {
  scope: {
    subscriptionId: '722ac943-eac8-4820-a689-00956825b76f'
    location: 'australiasoutheast'
  }
  name: '${environment}-${solution}-apps-rgp'
  tags: {
    function: solution
    environment: environment
    teams: 'ecom'
    costcentre: 'it'
    billto: 'tgg'
  }
  managedBy: ''
  properties: {}
}
