$zones = Get-AzDnsZone
$records = foreach ($zone in $zones) {
    Get-AzDnsRecordSet -ZoneName $zone.Name -ResourceGroupName $zone.ResourceGroupName
}
# Instala os modulos do excel
Find-Module -Name PowerShellGet | Install-Module
Find-Module -Name ImportExcel | Install-Module

# Combina as zonas e registros em um array unico
$data = foreach ($zone in $zones) {
    $records | Where-Object {$_.ZoneName -eq $zone.Name -and $_.ResourceGroupName -eq $zone.ResourceGroupName} |
        Select-Object *,@{n='Zone';e={$zone.Name}}
}

# Exporta para o arquivo
$data | Export-Excel -Path ".\dns_zones_records.xlsx"