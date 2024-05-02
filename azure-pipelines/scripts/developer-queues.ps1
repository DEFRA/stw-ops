
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
    $developerList,

    [Parameter()]
    [String]
    $QUEUE_SIZE,

    [Parameter()]
    [String]
    $DUPLICATION_DETECTION,

    [Parameter()]
    [String]
    $QUEUE_TTL,

    [Parameter()]
    [String]
    $CUSTOM_QUEUE,

    [Parameter()]
    [String]
    $DELETE_QUEUE,

    [Parameter()]
    [String[]]
    $CUSTOM_QUEUE_NAME_LIST
)


function devQueues ($devList) {

    $developersQueues = $devList.Split(",")
    Write-Host "List of Developers to create is: $developersQueues"

    foreach ($queueName in $developersQueues) {

        Write-Host " Creating queue for: $queueName"

        if (az servicebus queue list --resource-group $RESOURCE_GROUP --namespace-name $NAME_SPACE --query "[].name" -o tsv | grep $queueName) {
            Write-Host "The queue for $queueName already exists"
        }
        else {
            az servicebus queue create `
            --resource-group $RESOURCE_GROUP `
            --namespace-name $NAME_SPACE `
            --name $queueName `
            --max-size $QUEUE_SIZE `
            --enable-duplicate-detection $DUPLICATION_DETECTION `
            --default-message-time-to-live $QUEUE_TTL `
            --enable-session true
        }
    }
}

function createQueue ($CustomQueueName) {

    $newQueues = $CustomQueueName.Split(",")
    foreach ($Q in $newQueues) {
        if (az servicebus queue list --resource-group $RESOURCE_GROUP --namespace-name $NAME_SPACE --query "[].name" -o tsv | grep $Q) {
            Write-Host "The queue for $Q already exists"
        }
        else {
            az servicebus queue create `
            --resource-group $RESOURCE_GROUP `
            --namespace-name $NAME_SPACE `
            --name $Q `
            --max-size $QUEUE_SIZE `
            --enable-duplicate-detection $DUPLICATION_DETECTION `
            --default-message-time-to-live $QUEUE_TTL `
            --enable-session true
            write-host "$Q has been created"
        }
    }
}

function deleteQueue ($deleteQueueName) {

    $deleteQueues = $CustomQueueName.Split(",")

    foreach ($Q in $deleteQueues) {
        az servicebus queue delete --resource-group $RESOURCE_GROUP --namespace-name $NAME_SPACE --name $Q
        write-host "$Q servicebus queue has been delete"
    }



}

if ($CUSTOM_QUEUE -eq "true") {
    createQueue -CustomQueueName $CUSTOM_QUEUE_NAME_LIST
}
elseif ($DELETE_QUEUE -eq "true") {
    deleteQueue -deleteQueueName $CUSTOM_QUEUE_NAME_LIST
}
else {
    devQueues -devList $developerList
}