$subscriptions = Get-AzSubscription

$results = @()

foreach ($subscription in $subscriptions) {    
    Set-AzContext -SubscriptionId $subscription.Id

    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        $resourceGroupData = @{
            'ResourceGroup Name'         = $resourceGroup.ResourceGroupName
            'Subscription ID'            = $resourceGroup.SubscriptionId
            'Location'                   = $resourceGroup.Location
            'Tags'                       = $resourceGroup.Tags | Out-String
        }

        $results += New-Object PSObject -Property $resourceGroupData
    }
}

$results | Export-Csv -Path '.\resource-groups.csv'