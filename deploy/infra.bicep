@description('The location to deploy the resourcew.')
param location string = resourceGroup().location

// Create a suffix to make the resource names unique. 
// This is a good practice to avoid name conflicts in Azure resources.
@description('Suffix to append to the app name')
param appSuffix string = uniqueString(resourceGroup().id)

@description('ACR registry name.')
param containerRegistry string 

var containerRegistryName = '${containerRegistry}${appSuffix}'

@description('Key Vault name.')
param keyVaultName string = 'kv${appSuffix}'

@description('The name of the first sample secret.')
param secretname1 string

@secure()
@description('The value of the first sample secret.')
param secretvalue1 string

@description('The name of the second sample secret.')
param secretname2 string 

@secure()
@description('The value of the second sample secret.')
param secretvalue2 string


@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string = 'log-${appSuffix}'


@description('The name of the Application Insights workspace')
param appInsightsName string = 'appinsights-${appSuffix}'

// Create the log analytics workspace.
module logAnalytics 'modules/log.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Retrive the resource already set up so secret could be read and passed to the container app environment.
resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  dependsOn: [
    logAnalytics
  ]
}

// Create the application insights.
module appInsights 'modules/appInsights.bicep' = {
  name: appInsightsName
  params: {
    location: location
    appInsightsName: appInsightsName
  }
  dependsOn: [
    logAnalytics
  ]
}

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    location: location
    containerRegistryName: containerRegistryName
  }
}


module kvCreate 'modules/keyVault.bicep' = {
  name: 'kv'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

// Retrive the resource for the key vault just to be able to create the two sample secrets. Normally thay aren't created in a bicep.
resource kvResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
    name: keyVaultName
    dependsOn: [
      kvCreate
      log
    ]
}


// Create two secrets in the Key Vault as samples. They are going to be referenced in the container app deployment.
resource secret_One 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kvResource
  name: secretname1
  properties: {
    value: secretvalue1
  }
  dependsOn: [
    kvResource
  ]
}

resource secret_Two 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kvResource
  name: secretname2
  properties: {
    value: secretvalue2
  }
  dependsOn: [
    kvResource
  ]
}

resource secret_logCustomerKey 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kvResource
  name: 'logCustomerKey'
  properties: {
    value: log.properties.customerId
  }
  dependsOn: [
    kvResource
  ]
}

resource secret_logSharedKey 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kvResource
  name: 'logSharedKey'
  properties: {
    value: log.listKeys().primarySharedKey
  }
  dependsOn: [
    kvResource
  ]
}


