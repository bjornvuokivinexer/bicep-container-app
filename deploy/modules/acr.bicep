@description('The location to deploy the resource.')
param location string


@description('ACR registry name.')
param containerRegistryName string 

// Minimal setup of Container Registry.
resource arc 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}
