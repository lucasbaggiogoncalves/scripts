#--------------------------------------------------------------------------------------------------------------------
# This Script validates VM Tags. For it to work, the tags must be registered in the Vm target
#
# start-stop = true
# stop-time = HH:mm
# start-time = HH:mm
#--------------------------------------------------------------------------------------------------------------------

Disable-AzContextAutosave -Scope Process
$AzureContext = (Connect-AzAccount -Identity).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

# Resource Variables
$startTime = "06:00"
$vmLocation = "brazilsouth"

# Get VMs
$VMs = Get-AzVM | Where-Object {
    $_.Tags.ContainsKey('start-stop') -and $_.Tags['start-stop'] -eq 'true' `
    -and $_.Tags.ContainsKey('start-time') -and $_.Tags['start-time'] -eq $startTime `
    -and $_.Location -eq $vmLocation
}

# Start VMs
foreach ($Vm in $VMs) {
    Start-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name
}