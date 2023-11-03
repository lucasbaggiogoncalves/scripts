Connect-AzAccount

$subscriptions = Get-AzSubscription

$certificates = @()

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id

    $webApps = Get-AzWebApp
    
    foreach ($webApp in $webApps) {
        $sslbinding = Get-AzWebAppSSLBinding -ResourceGroupName $webApp.ResourceGroup -WebAppName $webapp.Name
        
        $certificates += [PSCustomObject]@{
            SubscriptionId = $subscription.Id
            ResourceGroup = $webApp.ResourceGroup
            WebApp = $webApp.Name
            SslBindingName = $sslbinding.Name -join ","
            SslState = $sslbinding.SslState -join ","
        }
    }
}

$certificates | Export-Csv -Path ".\sslbindings.csv" -NoTypeInformation