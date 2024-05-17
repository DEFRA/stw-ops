#!/usr/bin/env bash -e

buildPipelineId=$1

echo $buildPipelineId

echo $(System.AccessToken) | az devops login
RUN_PIPELINE=`az pipelines run --id $buildPipelineId --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration`
PIPELINE_ID=$(jq -r '.id' <<<"$RUN_PIPELINE")
echo $PIPELINE_ID
echo "Started the pipeline, listing the ones in progress:"
sleep 5
MY_RUN=`az pipelines build show --id $PIPELINE_ID --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration`
echo "and the pipeline is:"
echo $MY_RUN
STATE=$(jq -r '.status' <<<"$MY_RUN")
while [ $STATE != "completed" ]
do
    sleep 10
    MY_RUN=`az pipelines build show --id $PIPELINE_ID --org https://dev.azure.com/defragovuk/ --project DEFRA-STW-Integration`
    STATE=$(jq -r '.status' <<<"$MY_RUN")
    echo $STATE
done
echo "Done!"
