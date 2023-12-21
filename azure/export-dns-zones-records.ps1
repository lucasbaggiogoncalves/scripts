$dnsZones = Get-AzDnsZone

$results = @()

foreach ($zone in $dnsZones) {
    $recordSets = Get-AzDnsRecordSet -ZoneName $zone.Name -ResourceGroupName $zone.ResourceGroupName

    foreach ($recordSet in $recordSets) {   

        $result = [PSCustomObject]@{
            ResourceId = $recordSet.Id
            Name = $recordSet.Name
            ZoneName = $recordSet.ZoneName
            ResourceGroupName = $recordSet.ResourceGroupName
            TTL = $recordSet.Ttl
            RecordType = $recordSet.RecordType
            Records = $recordSet.Records -join ', '
            ProvisioningState = $recordSet.ProvisioningState
        }        

        $results += $result
    }
}

$results | Export-Csv -Path ".\dns-zones.csv" -NoTypeInformation