@description('The location to deploy the resource.')
param location string

@description('The name of the Application Insights workspace')
param appInsightsName string 

resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
