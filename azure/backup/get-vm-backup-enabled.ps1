Connect-AzAccount

$subscriptions = Get-AzSubscription

$results = @()

foreach ($subscription in $subscriptions) {
    
    Set-AzContext -SubscriptionId $subscription.Id

    $vms = Get-AzVM

    foreach ($vm in $vms) {
        
        $backupEnabled = Get-AzRecoveryServicesBackupStatus -ResourceId $vm.Id

        $result = [PSCustomObject]@{
            VMName = $vm.Name
            Subscription = $subscription.Name
            BackupEnabled = $backupEnabled.BackedUp
        }

        $results += $result
    }
}

$results | Export-Csv -Path "backup-status.csv" -NoTypeInformation
