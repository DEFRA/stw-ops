param (
    [string]$buildPipelineId
)

Write-Host $buildPipelineId

$RUN_PIPELINE = az pipelines run --id $buildPipelineId --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration
$PIPELINE_ID = ($RUN_PIPELINE | ConvertFrom-Json).id
Write-Host $PIPELINE_ID
Write-Host "Started the pipeline, listing the ones in progress:"
Start-Sleep -Seconds 5
$MY_RUN = az pipelines build show --id $PIPELINE_ID --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration
Write-Host "and the pipeline is:"
Write-Host $MY_RUN
$STATE = ($MY_RUN | ConvertFrom-Json).status
while ($STATE -ne "completed") {
    Start-Sleep -Seconds 10
    $MY_RUN = az pipelines build show --id $PIPELINE_ID --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration
    $STATE = ($MY_RUN | ConvertFrom-Json).status
    Write-Host $STATE
}
Write-Host "Done!"