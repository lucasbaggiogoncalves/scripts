# Lista todas as subs
$subscriptions = Get-AzSubscription

# Passa por cada sub
foreach ($subscription in $subscriptions) {

    # Seleciona sub atual
    Set-AzContext -SubscriptionId $subscription.Id
    
    # Lista todos os rgs da sub
    $resourceGroups = Get-AzResourceGroup

    # Passa por cada rg
    foreach ($resourceGroup in $resourceGroups) {

        # Remove a tag do rg
        Update-AzTag -ResourceId $resourceGroup.ResourceId -Tag @{"proc-gtm"= ""} -Operation Delete
    }
}