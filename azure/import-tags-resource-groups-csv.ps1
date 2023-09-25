Connect Az-Account

$tags = Import-Csv -Path '.\tags.csv'

foreach ($tag in $tags) {
    $Subscription = Get-AzSubscription -SubscriptionName $tag.Subscription
    $ResourceGroup = Get-AzResourceGroup -Name $tag.ResourceGroupName
    $TagName = $tag.TagName
    $TagValue = $tag.TagValue
    $MergedTags = @{"$TagName"="$TagValue"}

    Set-AzContext -Subscription $Subscription.Id

    Update-AzTag -ResourceId $ResourceGroup.ResourceId -Tag $MergedTags -Operation Merge }