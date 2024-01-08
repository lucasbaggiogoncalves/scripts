Connect-AzAccount

$results = @()

$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions){
    Set-AzContext -SubscriptionId $subscription.Id
   
    $resourcegroups = Get-AzResourceGroup
    foreach ($resourcegroup in $resourcegroups){
        if ($resourcegroup.Tags) {
            $resourcegrouptags = $resourcegroup.Tags
            $resourcegrouptagrateio = $resourcegrouptags['tag']
        }
        else {
            $resourcegrouptagrateio = $null
        }

        $resources = Get-AzResource -ResourceGroupName $resourcegroup.ResourceGroupName
        foreach ($resource in $resources) {
            if ($resource.Tags) {
                $resourcetags = $resource.Tags
                $resourcetagrateio = $resourcetags['tag']
            }
            else {
                $resourcetagrateio = $null
            }

            $results += [PSCustomObject] @{
                SubscriptionName = $subscription.Name
                ResourceGroup = $resourcegroup.ResourceGroupName
                Resource = $resource.Name
                ResourceId = $resource.Id
                ResourceGroupTagRateio = $resourcegrouptagrateio
                ResourceTagRateio = $resourcetagrateio
                }
        }
    }
}
$results | Export-Csv -Path ".\resourcegroup-resource-tag.csv" -NoTypeInformation