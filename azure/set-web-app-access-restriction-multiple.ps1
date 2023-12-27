Connect-AzAccount

# Resource variables
$subscription = "subname or id"
$webAppNames = @(
    "app1",
    "app2"
)

# IPs variables
$ipAddresses = @(
    "ip1",
    "ip2"
)

Set-AzContext -Subscription $subscription

# Initial priority (first rule)
$initialPriority = 200

# Loop through each web app
foreach ($webAppName in $webAppNames) {
    $WebApps = Get-AzWebApp -Name $webAppName

    foreach ($value in $ipAddresses) {
        Add-AzWebAppAccessRestrictionRule -ResourceGroupName $WebApps.ResourceGroup `
                                          -WebAppName $WebApps.Name `
                                          -Priority $initialPriority `
                                          -Action Allow `
                                          -IpAddress $value
                                        #   -SlotName "QAS"
                                          
        Write-Output "Rule for the range $value created for web app $webAppName" 

        # Increment the priority by 1 for each loop
        $initialPriority++
    }
}
