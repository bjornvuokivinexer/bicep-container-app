@description('The location to deploy the resource.')
param location string

@description('Key Vault name.')
param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    accessPolicies: [
      
    ]
  }
}







