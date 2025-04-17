# Info
Sample of create a Container App and pass secrets from KeyVault thru bicep.

How to use
- Login into Azure with az login
- Create a parameter for a resource group name and container registry.
- Create a resource group
- Deploy infra.bicep (Container registry and Key Vault, create two sample key vault secrets, secretOne and secretTwo).
- Deploy a container image to the Container Registry.
- Deploy main.bicep, set up the rest.


Login to Azure
```powershell
az login
```


 Create resouce group.
```powershell
$resourceGroupName = 'sample-resource-group'
$containerRegistry = 'acr'

az group create --name $resourceGroupName --location swedencentral
```
Run infra.bicep 

```powershell
az deployment group create --resource-group $resourceGroupName --template-file .\deploy\infra.bicep --parameters secretname1=secretone secretvalue1="secret value 1" secretname2=secrettwo secretvalue2="secret value 2" containerRegistry=$containerRegistry
```

Push a docker image to the Container Registry created by infra.bicep
In this sample the image name is *sampleprojects* and the image tag is *latest*.


Run main.bicep
```powershell
az deployment group create --resource-group $resourceGroupName --template-file .\deploy\main.bicep --parameters imageName=sampleprojects imageTag=latest containerRegistry=$containerRegistry

```








