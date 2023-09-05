Connect-AzAccount

$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {

  Set-AzContext -SubscriptionId $subscription.Id
  
  $resourceGroups = Get-AzResourceGroup

  foreach ($resourceGroup in $resourceGroups) {

    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName

    foreach ($resource in $resources) {

      Update-AzTag -ResourceId $resource.Id -Tag @{"proc-gtm"= ""} -Operation Delete
    }
  }
}
