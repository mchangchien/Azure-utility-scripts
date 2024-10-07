# Setup outfile path
$outputFilePath = "C:\temp\output.txt"
"Start the process" | Out-File -FilePath $outputFilePath

# Login to Azure account
Connect-AzAccount

# Set the subscription
Set-AzContext -Tenant "Your Tenant ID" -SubscriptionId "your subscription"

# Get all the Azure SQL servers in the subscription
$servers = Get-AzSqlServer

# Loop through each server and get its databases and failover groups
foreach ($server in $servers) {
    Write-Host "Server: $($server.ServerName)"
    Add-Content -Path $outputFilePath -Value "----------------------------------------------------------";
    Add-Content -Path $outputFilePath -Value "Processing Azure SQL Server: $($server.ServerName)";
    
    # Get the failover groups for the server
    $failoverGroups = Get-AzSqlDatabaseFailoverGroup -ResourceGroupName $server.ResourceGroupName -ServerName $server.ServerName

    # Loop through each database on the server
    foreach ($database in Get-AzSqlDatabase -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName) {
        Write-Host "  Database: $($database.DatabaseName)"
        Add-Content -Path $outputFilePath -Value "Database: $($database.DatabaseName)  Server: $($server.ServerName)";
        # Get the failover group associated with the database, if any
        $failoverGroup = $failoverGroups | Where-Object { $_.DatabaseNames -contains $database.DatabaseName }
        
        if ($failoverGroup) {
            Write-Host "    Failover Group: $($failoverGroup.FailoverGroupName)"
            Add-Content -Path $outputFilePath -Value "Failover Group: $($failoverGroup.FailoverGroupName)";
        }
        else {
            Write-Host "    No Failover Group"
            Add-Content -Path $outputFilePath -Value "No Failover Group";
        }
    }
}