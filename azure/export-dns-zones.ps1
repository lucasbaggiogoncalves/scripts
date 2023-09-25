$zones = Get-AzDnsZone
$records = foreach ($zone in $zones) {
    Get-AzDnsRecordSet -ZoneName $zone.Name -ResourceGroupName $zone.ResourceGroupName
}

Find-Module -Name PowerShellGet | Install-Module
Find-Module -Name ImportExcel | Install-Module


$data = foreach ($zone in $zones) {
    $records | Where-Object {$_.ZoneName -eq $zone.Name -and $_.ResourceGroupName -eq $zone.ResourceGroupName} |
        Select-Object *,@{n='Zone';e={$zone.Name}}
}


$data | Export-Excel -Path ".\dns_zones_records.xlsx"