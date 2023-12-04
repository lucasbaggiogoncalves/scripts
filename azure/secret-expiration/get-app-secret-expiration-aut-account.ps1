#AzureAuth

try{                
	# Ensures you do not inherit an AzContext in your runbook
	Disable-AzContextAutosave -Scope Process
	# Connect to Azure with system-assigned managed identity
	$AzureContext = (Connect-AzAccount -Identity).context
	# set and store context
	$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
	Write-Output "Authentication succeded."
} catch {
	throw "Unable to authenticate.`n$($_.Exception)"
} 

Function Set-CellColor
{ 
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position=0)]
        [string]$Property,
        [Parameter(Mandatory,Position=1)]
        [string]$Color,
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]$InputObject,
        [Parameter(Mandatory)]
        [string]$Filter,
        [switch]$Row
    )
    
    Begin {
        Write-Verbose "$(Get-Date): Function Set-CellColor begins"
        If ($Filter)
        {   If ($Filter.ToUpper().IndexOf($Property.ToUpper()) -ge 0)
            {   $Filter = $Filter.ToUpper().Replace($Property.ToUpper(),"`$Value")
                Try {
                    [scriptblock]$Filter = [scriptblock]::Create($Filter)
                }
                Catch {
                    Write-Warning "$(Get-Date): ""$Filter"" caused an error, stopping script!"
                    Write-Warning $Error[0]
                    Exit
                }
            }
            Else
            {   Write-Warning "Could not locate $Property in the Filter, which is required.  Filter: $Filter"
                Exit
            }
        }
    }
    
    Process {
        ForEach ($Line in $InputObject)
        {   If ($Line.IndexOf("<tr><th") -ge 0)
            {   Write-Verbose "$(Get-Date): Processing headers..."
                $Search = $Line | Select-String -Pattern '<th ?[a-z\-:;"=]*>(.*?)<\/th>' -AllMatches
                $Index = 0
                ForEach ($Match in $Search.Matches)
                {   If ($Match.Groups[1].Value -eq $Property)
                    {   Break
                    }
                    $Index ++
                }
                If ($Index -eq $Search.Matches.Count)
                {   Write-Warning "$(Get-Date): Unable to locate property: $Property in table header"
                    Exit
                }
                Write-Verbose "$(Get-Date): $Property column found at index: $Index"
            }
            If ($Line -match "<tr( style=""background-color:.+?"")?><td")
            {   $Search = $Line | Select-String -Pattern '<td ?[a-z\-:;"=]*>(.*?)<\/td>' -AllMatches
                $Value = $Search.Matches[$Index].Groups[1].Value -as [double]
                If (-not $Value)
                {   $Value = $Search.Matches[$Index].Groups[1].Value
                }
                If (Invoke-Command $Filter)
                {   If ($Row)
                    {   Write-Verbose "$(Get-Date): Criteria met!  Changing row to $Color..."
                        If ($Line -match "<tr style=""background-color:(.+?)"">")
                        {   $Line = $Line -replace "<tr style=""background-color:$($Matches[1])","<tr style=""background-color:$Color"
                        }
                        Else
                        {   $Line = $Line.Replace("<tr>","<tr style=""background-color:$Color"">")
                        }
                    }
                    Else
                    {   Write-Verbose "$(Get-Date): Criteria met!  Changing cell to $Color..."
                        $Line = $Line.Replace($Search.Matches[$Index].Value,"<td style=""background-color:$Color"">$Value</td>")
                    }
                }
            }
            Write-Output $Line
        }
    }
    
    End {
        Write-Verbose "$(Get-Date): Function Set-CellColor completed"
    }
}

Function Get-AZSPInfo
{

$AZSPInfoBody = @"
<h1>Azure Service Principal Report</h1>
<p>O script rodou em: $(Get-Date -Format dd-MM-yyyy)</p>

"@

    $ADSPs = Get-AzADApplication
    $CustomReport = @()
    foreach ($ADSP in $ADSPs)
    {
        $AZADAppCreds = Get-AzADAppCredential -ApplicationId $ADSP.AppID
        foreach ($AZADAppCred in $AZADAppCreds)
        {
            $EndDate = $AZADAppCred.EndDateTime
            $Currentdate = Get-Date
            $diffDays = (New-TimeSpan -Start $Currentdate -End $EndDate).Days
    
            $SPReport = New-Object PSObject
            $SPReport | Add-Member -type NoteProperty -name DisplayName -Value $ADSP.DisplayName
            $SPReport | Add-Member -type NoteProperty -name AppID -Value $ADSP.AppID
            $SPReport | Add-Member -type NoteProperty -name StartDate -Value $AZADAppCred.StartDateTime
            $SPReport | Add-Member -type NoteProperty -name EndDate -Value $AZADAppCred.EndDateTime
            $SPReport | Add-Member -type NoteProperty -name DaysToExpire -Value $diffDays
            $SPReport | Add-Member -type NoteProperty -name Type -Value $(if ($AZADAppCred.Type -eq "AsymmetricX509Cert") { "AsymmetricX509Cert" }
            else { "Secret" })
            $CustomReport += $SPReport
        }
    }

    $AZSPInfo = $CustomReport | Sort-Object { $_.enddate -as [datetime] }
    $AZSPInfoHTML = $AZSPInfo | ConvertTo-HTML | Set-CellColor DaysToExpire yellow -Filter "DaysToExpire -lt 90"
    $AZSPInfoHTML = $AZSPInfoHTML | Set-CellColor DaysToExpire red -Filter "DaysToExpire -lt 30"
    $AZSPInfoHTML = $AZSPInfoHTML | Set-CellColor DaysToExpire green -Filter "DaysToExpire -ge 90"
    $AZSPInfoBody + $AZSPInfoHTML
}

Write-Host "- Capturing Service Principal Expiration Information. " -ForegroundColor Yellow
Write-Host " "
$AZSPHTML = Get-AZSPInfo # Pull report for Service Principal expiration

# HTML Title
$Title = @"
<title>Azure Service Principal Report</title>

"@

# HTML Header
$Header = @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px; background-color: #d1c3cd;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
"@

# Combine HTML Reports
$FinalHTML = $Title + $Header + $AZSPHTML

# Export HTML Report to a storage account container

$storageAccName = "storageacc"
$storageAccKey = "storagesecret"

$context = New-AzStorageContext -StorageAccountName $storageAccName -StorageAccountKey $storageAccKey

$containerName = "serviceprincipalsecretsexpiration"

$FinalHTML | Out-File -FilePath ".\$(Get-Date -Format 'dd-MM-yyyy').html"

Set-AzStorageBlobContent -Context $context -Container $containerName -File ".\$(Get-Date -Format 'dd-MM-yyyy').html"
