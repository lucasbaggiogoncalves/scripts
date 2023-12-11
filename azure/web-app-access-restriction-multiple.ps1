Connect-AzAccount

# Resource variables
$subscription = "subname-or-subid"
$resourceGroupName = "rgname"
$webAppName = "webappname"

Set-AzContext -Subscription $subscription

# IPs variables
$ipAddresses = @(
    "value1",
    "value2",
    "value3",
)

# Initial priority (first rule)
$initialPriority = 200

# Loop through each IP
foreach ($value in $ipAddresses) {
    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $resourceGroupName `
                                      -WebAppName $webAppName `
                                      -Priority $initialPriority `
                                      -Action Allow `
                                      -IpAddress $value
                                      
    Write-Output "Rule for the range $value created" 

    # Increment the priority by 1 for each loop
    $initialPriority++
}
