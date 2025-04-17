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


