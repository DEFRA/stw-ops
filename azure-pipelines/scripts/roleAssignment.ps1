
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $CONTAINER_REGISTRY,

    [Parameter()]
    [String]
    $RESOURCE_GROUP,

    [Parameter()]
    [String[]]
    $MANAGED_IDENTITY_NAME,

    [Parameter()]
    [String[]]
    $ROLE
)


$modulePath = Get-Location
$modulePath = "$($modulePath)\azure-pipelines\scripts\modules"

Import-Module "$modulePath\createRoleAssignment"

createRoleAssignment -CONTAINER_REGISTRY $CONTAINER_REGISTRY -RESOURCE_GROUP $RESOURCE_GROUP -MANAGED_IDENTITY $MANAGED_IDENTITY_NAME -ROLE $ROLE