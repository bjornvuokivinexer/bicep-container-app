@description('The location to deploy the resource.')
param location string

@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}



