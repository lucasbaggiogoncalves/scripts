Install-Module Az.Reservations

Connect-AzAccount -Tenant 812a6bd0-5829-4196-b2be-d0580b7bd0cb 

$ROids = (Get-AzReservationOrder).id 
ForEach ($roid in $roids) 
{ 

New-AzRoleAssignment -Scope $roid -RoleDefinitionName "Reader" -ApplicationId "489fe005-26ab-40f8-a02d-5434232f6610" 

}