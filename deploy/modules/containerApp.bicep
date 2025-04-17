@description('The location to deploy the resource.')
param location string

@description('Container App Environment name.')
param containerAppName string


@description('Container Registry name.')
param containerRegistryName string

@description('Application Insights workspace.')
param appInsightsName string


@description('Container App Environment name.')
param containerAppEnvironmentName string 

@description('The name of the user assigned identity')
param userAssignedIdentityName string

@description('Image tag to deploy.')
param imageTag string 

@description('Image name to deploy.')
param imageName string 

// Mark as secrets, inject them thru the module call.
@secure()
param secretOne string 

@secure()
param secretTwo string


// Built in roles, see: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var  acrPullDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name:containerRegistryName
}

// Retrive resources already set up
resource env 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvironmentName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}


// Create a user assigned identity for the container app to use.
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: userAssignedIdentityName
  location: location 
}

// Assign the AcrPull role to the identity for the container registry.
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, acr.name, 'AcrPullTestUserAssigned')
  properties: {
    principalId: identity.properties.principalId  
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinitionId)
  }
}





// Create the container app.
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          // Container registry name
          server: '${acr.name}.azurecr.io'
          identity: identity.id
        }
      ]
      secrets: [
        // Sample secrets that can be referenced in env variables.
        {
          name: 'app-insights-key'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'app-insights-connection-string'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'app-secretone-kv'
          value: secretOne
        }  
        {
          name: 'app-secrettwo-kv'
          value: secretTwo
        }      
        {
          name: 'app-insights-key'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'app-insights-connection-string'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'app-secretone'
          value: secretOne
        }  
        {
          name: 'app-secrettwo-kv'
          value: secretTwo
        }          
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: '${acr.name}.azurecr.io/${imageName}:${imageTag}'
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          env: [
            // Env variables.
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              secretRef: 'app-insights-key'               // Reference to the secret created above.
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'app-insights-connection-string' // Reference to the secret created above.
            }
            {
              name: 'MyConfig__AppName'
              secretRef: 'app-secretone-kv'               // Reference to the secret created above.
            }
            {
              name: 'MyConfig__Version'
              secretRef: 'app-secrettwo-kv'               // Reference to the secret created above.
            }
            {
              name: 'MyConfigAppName'
              secretRef: 'app-secretone-kv'               // Reference to the secret created above.
            }
            {
              name: 'MyConfigVersion'
              secretRef: 'app-secrettwo-kv'               // Reference to the secret created above.
            }            
            
            {
              name: 'SimpleEnvVar' 
              value: 'SimpleEnvVarValue'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
      }
    }
  }
  // Managed identity
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
}
