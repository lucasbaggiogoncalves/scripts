Connect-AzAccount

$subscriptions = Get-AzSubscription

$results = @()

foreach ($subscription in $subscriptions) {
    Set-AzContext -Subscription $subscription.Id
    
    $resources = Get-AzResource
    
    foreach ($resource in $resources) {
        $permissions = Get-AzRoleAssignment -Scope $resource.Id

        foreach ($permission in $permissions) {

            $result = [PSCustomObject]@{
                Subscription       = $subscription.Name
                ResourceGroup      = $resource.ResourceGroupName
                ResourceName       = $resource.Name
                ResourceType       = $resource.ResourceType
                UserOrRole         = $permission.DisplayName
                RoleDefinitionName = $permission.RoleDefinitionName
            }

            $results += $result
        }      
    }
}

$results | Export-Csv -Path ".\all-permissions.csv" -NoTypeInformation