param managedIdentityName string

param location string

param tags object

resource symbolicname 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}
