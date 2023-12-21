Connect-AzAccount

$firewallrules = Import-Csv -Path '.\firewallrules.csv'

foreach ($firewallrule in $firewallrules) {
    $subscription = Get-AzSubscription -SubscriptionName $firewallrule.Subscription
    $resourcegroup = Get-AzResourceGroup -Name $firewallrule.ResourceGroupName
    $servername = $firewallrule.ServerName
    $firewallrulename = $firewallrule.FirewallRuleName
    $startip = $firewallrule.StartIpAddress
    $endip = $firewallrule.EndIpAddress

    Set-AzContext -Subscription $subscription.Id

    New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroup.ResourceGroupName -ServerName $servername -FirewallRuleName $firewallrulename -StartIpAddress $startip -EndIpAddress $endip }