
@description('The location to deploy the resource.')
param location string


@description('The name of the Container App Environment')
param containerAppEnvironmentName string 


@description('Log analytics Customer Id')
param logAnalyticsCustomerId string 


@description('Log analytics shared key')
param logAnalyticsSharedKey string 



resource env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppEnvironmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
  }
}
