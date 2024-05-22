
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $RESOURCE_GROUP,

    [Parameter()]
    [String]
    $NAME_SPACE,

    [Parameter()]
    [String[]]
    $DEVELOPER_LIST
)


$modulePath = Get-Location
$modulePath = "$($modulePath)\azure-pipelines\scripts\modules"

Import-Module "$modulePath\deleteQueue"

$deleteQueue = $DEVELOPER_LIST.Split(",")

foreach ($DEVQUEUE in $deleteQueue) {
    deleteServicebusQueue -RESOURCE_GROUP $RESOURCE_GROUP -NAME_SPACE $NAME_SPACE -QUEUE_NAME $DEVQUEUE
    Write-Host "$DEV queue deleted"
    Write-Host "$NAME_SPACE Namespace name "
}