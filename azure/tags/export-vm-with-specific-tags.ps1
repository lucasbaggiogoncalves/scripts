$subscriptions = Get-AzSubscription

$vmDetails = @()

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id
    
    $vms = Get-AzVM | Where-Object {
        $_.Tags.ContainsKey('start-stop') -and $_.Tags['start-stop'] -eq 'true' }

    foreach ($vm in $vms) {
    
        $startTime = $vm.Tags['start-time']
        $stopTime = $vm.Tags['stop-time']

        $vmObject = [PSCustomObject]@{
            Subscription      = $subscription.Name
            ResourceGroupName = $vm.ResourceGroupName
            Name              = $vm.Name
            StartTime         = $startTime
            StopTime          = $stopTime
        }

        $vmDetails += $vmObject
    }
}

$vmDetails | Export-Csv -Path "./vm-with-tags.csv" -NoTypeInformation