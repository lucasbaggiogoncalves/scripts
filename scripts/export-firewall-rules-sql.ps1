# Autenticar no Azure
Connect-AzAccount

# Obter todas as assinaturas
$subscriptions = Get-AzSubscription

# Inicializar um array vazio para armazenar todas as regras de firewall
$allFirewallRules = @()

# Iterar por cada assinatura
foreach ($subscription in $subscriptions) {
    Write-Output "Processando Assinatura: $($subscription.Name)"
    Select-AzSubscription -SubscriptionId $subscription.Id

    # Obter todos os servidores SQL na assinatura atual
    $sqlServers = Get-AzSqlServer

    # Iterar por cada servidor SQL
    foreach ($sqlServer in $sqlServers) {
        Write-Output "Processando Servidor SQL: $($sqlServer.ServerName)"

        # Obter todas as regras de firewall para o servidor SQL atual
        $firewallRules = Get-AzSqlServerFirewallRule -ServerName $sqlServer.ServerName -ResourceGroupName $sqlServer.ResourceGroupName

        # Adicionar as regras de firewall ao array
        $allFirewallRules += $firewallRules
    }
}

# Exportar todas as regras de firewall para o CSV
$allFirewallRules | Export-Csv -Path "allfirewallrules-sql.csv" -NoTypeInformation

