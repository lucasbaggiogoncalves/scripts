Connect-AzAccount

$subscriptions = Get-AzSubscription

$allFirewallRules = @()

foreach ($subscription in $subscriptions) {
    Write-Output "Processando Assinatura: $($subscription.Name)"
    Select-AzSubscription -SubscriptionId $subscription.Id

    $sqlServers = Get-AzSqlServer

    foreach ($sqlServer in $sqlServers) {
        Write-Output "Processando Servidor SQL: $($sqlServer.ServerName)"

        $firewallRules = Get-AzSqlServerFirewallRule -ServerName $sqlServer.ServerName -ResourceGroupName $sqlServer.ResourceGroupName

        $allFirewallRules += $firewallRules
    }
}

$allFirewallRules | Export-Csv -Path "allfirewallrules-sql.csv" -NoTypeInformation

