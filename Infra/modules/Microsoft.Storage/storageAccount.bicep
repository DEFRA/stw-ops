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
