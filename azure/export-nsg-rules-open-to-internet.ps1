Connect-AzAccount

$subscriptions = Get-AzSubscription

$results = @()

foreach ($subscription in $subscriptions) {
    Select-AzSubscription -Subscription $subscription.Id

    $nsgs = Get-AzNetworkSecurityGroup

    foreach ($nsg in $nsgs) {
        $rules = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg | Where-Object { $_.Direction -eq 'Inbound' -and $_.Access -eq 'Allow' }

        foreach ($rule in $rules) {
            if ($rule.SourcePortRange -eq '*' -and $rule.SourceAddressPrefix -eq '*' -or $rule.SourceAddressPrefix -eq 'Internet') {

                $result = [PSCustomObject]@{
                    Subscription = $subscription.Name
                    NSGName = $nsg.Name
                    RuleName = $rule.Name
                    DestinationPort = $rule.DestinationPortRange -join ', '
                }

                $results += $result
            }
        }
    }
}

$results | Export-Csv -Path ".\nsg-rules-open-to-internet.csv" -NoTypeInformation
