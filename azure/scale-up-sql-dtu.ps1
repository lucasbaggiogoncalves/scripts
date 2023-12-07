#Azure Auth

try {                
    Disable-AzContextAutosave -Scope Process
    $AzureContext = (Connect-AzAccount -Identity).context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
    Write-Output "Authentication succeded."
}
catch {
    throw "Unable to authenticate.`n$($_.Exception)"
} 

# Get Automation Variables

$storageName = Get-AutomationVariable -Name "autstorageaccname"
$storageKey = Get-AutomationVariable -Name "autstorageacckey"
$leadsrgname = Get-AutomationVariable -Name "leadsrgname"
$leadsservername = Get-AutomationVariable -Name "leadsservername"
$leadsdatabasename = Get-AutomationVariable -Name "leadsdatabasename"

$dtuSize = (Get-AzSqlDatabase -ResourceGroupName $leadsrgname -ServerName $leadsservername -DatabaseName $leadsdatabasename).RequestedServiceObjectiveName

Write-Host "Size atual =" $dtuSize

$newDtuSize = ""
switch ($dtuSize) {
    "S2" { $newDtuSize = "S3" }
    "S3" { $newDtuSize = "S4" }

    Default { Write-Host "Não pode ser escalado além do limite de S4" }
}

if ($newDtuSize -ne "") {
    Write-Host "Alterando size de" $dtuSize "para" $newDtuSize
    Set-AzSqlDatabase -ResourceGroupName $leadsrgname -ServerName $leadsservername -DatabaseName $leadsdatabasename -Edition "Standard" -RequestedServiceObjectiveName $newDtuSize   
    Write-Host "Size alterado para" $newDtuSize
    
    $output = [PSCustomObject]@{
        GrupoDeRecursos = $leadsrgname
        Servidor        = $leadsservername
        Database        = $leadsdatabasename
        SizeAntigo      = $dtuSize
        SizeAlterado    = $newDtuSize
    }
}

Write-Output = ($output | ConvertTo-Json)

$jsonOutput = ($output | ConvertTo-Json)
$jsonOutput | Out-File -FilePath ".\scaleup.json"

# Storage Account Variables

$containerName = "databaseleadsscaledtu"
$blobname = "scaleup.json"

$context = New-AzStorageContext -StorageAccountName $storageName -StorageAccountKey $storageKey

Set-AzStorageBlobContent -Context $context -Container $containerName -File ".\scaleup.json" -Blob $blobname