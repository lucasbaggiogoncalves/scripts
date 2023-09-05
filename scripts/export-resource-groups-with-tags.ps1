Find-Module -Name PowerShellGet | Install-Module
Find-Module -Name ImportExcel | Install-Module

# Get all Azure subscriptions
$subscriptions = Get-AzSubscription

# Create an empty array for storing the results
$results = @()

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscription.Id

    # Get all resource groups in the current subscription
    $resourceGroups = Get-AzResourceGroup

    # Iterate through each resource group
    foreach ($resourceGroup in $resourceGroups) {
        # Create a hashtable to store the data for each resource group
        $resourceGroupData = @{
            'ResourceGroup Name'         = $resourceGroup.ResourceGroupName
            'Subscription ID'            = $resourceGroup.SubscriptionId
            'Location'                   = $resourceGroup.Location
            'Tags'                       = $resourceGroup.Tags | Out-String
        }

        # Add the hashtable to the results array
        $results += New-Object PSObject -Property $resourceGroupData
    }
}

# Export the results to an Excel file
$results | Export-Excel -Path '.\resource-groups.xlsx'