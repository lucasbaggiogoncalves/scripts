$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {

    Set-AzContext -SubscriptionId $subscription.Id
    
    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {

        Update-AzTag -ResourceId $resourceGroup.ResourceId -Tag @{"proc-gtm"= ""} -Operation Delete
    }
}