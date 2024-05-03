param name string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
name: name
location: location
sku: {
  name: 'Standard_ZRS'
 }
 kind: 'StorageV2'
}

// var storageAccountName = storageAccount.name
// var storageAccountId = storageAccount.id
// var storageAccountApiVersion = storageAccount.apiVersion


// output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId, storageAccountApiVersion).keys[0].value};EndpointSuffix=core.windows.net'
