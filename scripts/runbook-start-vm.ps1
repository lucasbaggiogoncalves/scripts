# Nao segmentar AzContext no run
Disable-AzContextAutosave -Scope Process

# Connectar no Azure usando o contexto de identidade
$AzureContext = (Connect-AzAccount -Identity).context

# Setar o contexto
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContex

# Especificar RG e VM (caso necessario)
Start-AzVM -ResourceGroupName "RG" -name "VM"