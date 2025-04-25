@description('Application suffix that will be applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location to deploy all my resources')
param location string = resourceGroup().location

@description('The name of the Container App Environment')
param containerAppEnvironmentName string = 'env${appSuffix}'

@description('The name of the Key Vault')
param keyVaultName string = 'kv${appSuffix}'

@description('ACR registry name.')
param containerRegistry string 

@description('The name of the user assigned identity')
param userAssignedIdentityName string = 'identity-${appSuffix}'

@description('Image tag to use')
param imageTag string = 'latest'

@description('Image name to use')
param imageName string = 'sampleprojects'

var containerAppName = 'sampleapp-${appSuffix}'
@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string = 'log-${appSuffix}'

@description('The name of the Application Insights workspace')
param appInsightsName string = 'appinsights-${appSuffix}'

var containerRegistryName = '${containerRegistry}${appSuffix}'

// Retrive the resource already set up so secret could be read and passed to the container app environment.
resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}


// Retrive the key vault resoutce already set up so secret could be read and passed to the container app environment.
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}



module containerAppEnvironment 'modules/appEnvironment.bicep' = {
  name: containerAppEnvironmentName
  params: {
    location: location
    containerAppEnvironmentName: containerAppEnvironmentName
    logAnalyticsCustomerId: log.properties.customerId
    logAnalyticsSharedKey: log.listKeys().primarySharedKey
  }
}

module ca 'modules/containerApp.bicep' = {
  name: containerAppName
  params: {
    location: location
    
    containerAppName: containerAppName
    containerRegistryName: containerRegistryName
    appInsightsName: appInsightsName
    containerAppEnvironmentName: containerAppEnvironmentName    
    userAssignedIdentityName: userAssignedIdentityName
    imageTag: imageTag
    imageName: imageName
    secretOne: kv.getSecret('SecretOne')  // Pass a secret from key vault to the container app. This can only be done as parameter to the module, not as a variable.
    secretTwo: kv.getSecret('SecretTwo')  // Pass a secret from key vault to the container app. This can only be done as parameter to the module, not as a variable.

  }
  dependsOn: [
    log
    containerAppEnvironment
  ]
}



