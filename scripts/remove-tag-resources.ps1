Connect-AzAccount

# Lista todas as subs
$subscriptions = Get-AzSubscription

# Passa por cada sub
foreach ($subscription in $subscriptions) {

  # Seleciona a sub atual
  Set-AzContext -SubscriptionId $subscription.Id
  
  # Lista todos os rgs da sub
  $resourceGroups = Get-AzResourceGroup

  foreach ($resourceGroup in $resourceGroups) {

    # Lista todos os recursos de um rg
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName

    foreach ($resource in $resources) {

      # Remove a tag do recurso
      Update-AzTag -ResourceId $resource.Id -Tag @{"proc-gtm"= ""} -Operation Delete
    }
  }
}
