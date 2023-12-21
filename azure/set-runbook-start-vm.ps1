Disable-AzContextAutosave -Scope Process

$AzureContext = (Connect-AzAccount -Identity).context

$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContex

Start-AzVM -ResourceGroupName "RG" -name "VM"