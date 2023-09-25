Connect-AzAccount

$results = @()

$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id

    $vms = Get-AzVM
    foreach ($vm in $vms) {
        $resourceGroupName = $vm.ResourceGroupName
        $vmName = $vm.Name

        $roleAssignments = Get-AzRoleAssignment -ResourceGroupName $resourceGroupName -ResourceType $vm.Type -ResourceName $vm.Name

        foreach ($roleAssignment in $roleAssignments) {
            if ($roleAssignment.RoleDefinitionName -eq "Contributor" -Or $roleAssignment.RoleDefinitionName -eq "Owner") {
                $results += [PSCustomObject]@{
                    SubscriptionName = $subscription.Name
                    ResourceGroupName = $resourceGroupName
                    VMName = $vmName
                    UserDisplayName = $roleAssignment.DisplayName
                    UserSignInName = $roleAssignment.SignInName
                    ObjectType = $roleAssignment.ObjectType
                    RoleDefinitionName = $roleAssignment.RoleDefinitionName
                }
            }
        }
    }
}

$results | Export-Csv -Path ".\user-role-vms.csv" -NoTypeInformation