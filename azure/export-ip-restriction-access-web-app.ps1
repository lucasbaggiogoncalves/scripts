# Resource variables
$subscription = "sub"
$resourceGroups = @("rg1","rg2")

$APIVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes | Where-Object ResourceTypeName -eq sites).ApiVersions[0]
$results = @()

Set-AzContext -Subscription $subscription

foreach ($resourceGroup in $resourceGroups) {
    $webApps = (Get-AzWebApp -ResourceGroupName $resourceGroup)

    foreach ($webApp in $webApps) {
        
        $webAppConfig = (Get-AzResource -ResourceType Microsoft.Web/sites/config -ResourceName $webApp.Name -ResourceGroupName $webApp.ResourceGroup -ApiVersion $APIVersion)
        $ipRestrictions = $webAppConfig.Properties.IpSecurityRestrictions
        
        foreach ($ipRestriction in $ipRestrictions){
            $results += [PSCustomObject]@{

                Subscription = $subscription
                ResourceGroup = $WebApp.ResourceGroup
                WebApp = $webApp.Name
                RuleName = $ipRestriction.Name
                RuleDescription = $ipRestriction.Description
                RuleAction = $ipRestriction.Action
                RulePriority = $ipRestriction.Priority
                RuleIp = $ipRestriction.ipAddress

            }
        }
    }
}

# Export results
$results | Export-Csv -Path ".\web-app-access-restriction.csv" -NoTypeInformation
