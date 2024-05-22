function deleteServicebusQueue ($RESOURCE_GROUP, $NAME_SPACE, $QUEUE_NAME) {

    az servicebus queue delete --resource-group $RESOURCE_GROUP --namespace-name $NAME_SPACE --name $QUEUE_NAME
}

Export-ModuleMember -Function deleteServicebusQueue