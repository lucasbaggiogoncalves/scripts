Connect-AzAccount

$currentDate = Get-Date -Format "dd-MM-yyyy"

# Infos to fill
$SubscriptionId = "Sub-ID"
$resourceGroupName = "RG-Name"
$vmName = "VM-Name"

Set-AzContext -SubscriptionId $SubscriptionId

$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# OS disk snapshot
$snapshotNameOS = "incremental-snapshot-" + $vm.Name + "-" + "OS-" + $currentDate
$snapshotConfigOS = New-AzSnapshotConfig -SourceResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id -CreateOption Copy -Incremental -Location $vm.Location -AccountType Standard_LRS
New-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotNameOS -Snapshot $snapshotConfigOS 

# Data disks snapshot
foreach ($disk in $vm.StorageProfile.DataDisks) {
    $snapshotNameData = "incremental-snapshot-" + $vm.Name + "-" + "DATA" + "-" + "lun" + $disk.Lun + "-" + $currentDate
    $snapshotConfigData = New-AzSnapshotConfig -SourceResourceId $disk.ManagedDisk.Id -CreateOption Copy -Incremental -Location $vm.Location -AccountType Standard_LRS
    New-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotNameData -Snapshot $snapshotConfigData
}