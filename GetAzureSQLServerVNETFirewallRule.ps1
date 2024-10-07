# Setup outfile path
$outputFilePath = "C:\temp\output.txt"
"Start the process" | Out-File -FilePath $outputFilePath

# Login to Azure
Connect-AzAccount -WarningAction SilentlyContinue

# Set to the current tenant and subscription
Set-AzContext -Tenant "Your Tenant ID" -Subscription "Your Subscription ID"

# Print the current tenant and subscription
Get-AzContext | Out-File -FilePath $outputFilePath -Append

# List all SQL servers in the subscription
$sqlServers = Get-AzSqlServer

Add-Content -Path $outputFilePath -Value "======================================================================================================================"
Write-Output "======================================================================================================================"

foreach ($sqlServer in $sqlServers) {
    Add-Content -Path $outputFilePath -Value "Listing virtual network rules for SQL Server: $($sqlServer.ServerName)"
    Write-Output "Listing virtual network rules for SQL Server: $($sqlServer.ServerName)"
    
    $vnetRules = Get-AzSqlServerVirtualNetworkRule -ResourceGroupName $sqlServer.ResourceGroupName -ServerName $sqlServer.ServerName
    if ($vnetRules) {
        $vnetRules | Out-File -FilePath $outputFilePath -Append
    } else {
        Add-Content -Path $outputFilePath -Value "No virtual network rules found for SQL Server: $($sqlServer.ServerName)"
    }

    Add-Content -Path $outputFilePath -Value "======================================================================================================================"
    Write-Output "======================================================================================================================"
}

Add-Content -Path $outputFilePath -Value "Process complete."
Write-Output "Process complete."
