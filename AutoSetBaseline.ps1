# script name: AutoSetBaseline.ps1
# author: Matt Changchien(matt.changchien@microsoft.com)
# purpose: To automatically run the the VA query and set the qeury result as baseline
# How to use:
#           1. determine which  VA(vulnerability Assessment) rule you would like to reset the baseline
#           2. go to Azure Portal to copy that VA rule's query and paste it for $baseline_query
#           3. adjust $rule_id to the rule that you just copy the query of
#           4. set up the server account and password, it's recommended to us SQL Server admin so that it has permission to run VA query under each databases
#               4.a Only set up the server that you want to adjust baseline for its databases
#

# predefined parameters
$ServerAccountPwd = @{
mchangchien0705 = @{'ServerName' = 'mchangchien0705'; 'ServerInstance' =  'mchangchien0705.database.windows.net'; 'Username' = 'azureuser'; 'Password' = 'Azure@User123'};
mchangchien0501 = @{'ServerName' = 'mchangchien0501'; 'ServerInstance' =  'mchangchien0501.database.windows.net'; 'Username' = 'azureuser'; 'Password' = 'Azure@User123'}}

$baseline_query = "SELECT USER_NAME(member_principal_id) AS [Owner] FROM sys.database_role_members WHERE USER_NAME(role_principal_id) = 'db_owner' AND USER_NAME(member_principal_id) != 'dbo'"

$params = @{'Database' = 'Database1'; 'ServerInstance' =  'mchangchien0705.database.windows.net'; 'Username' = 'azureuser'; 'Password' = 'Azure@User123'; 'OutputSqlErrors' = $true;
		'Query' = "SELECT USER_NAME(member_principal_id) AS [Owner] FROM sys.database_role_members WHERE USER_NAME(role_principal_id) = 'db_owner' AND USER_NAME(member_principal_id) != 'dbo'" }

$rule_id = 'VA1258'



# ------------- main line -------------

# first we get a list of sql server and go through each of them
# then we only deal with  servers that have account has password defined in $ServerAccountPwd

$server_result = Get-AzResourceGroup | Get-AzSqlServer
For ($i = 0; $i -lt $server_result.count; $i++)
{
	Write-host "----------------------------"; 
  Write-host $server_result[$i].servername; 
	#Write-host $server_result[$i].resourcegroupname; 
	#Write-host $server_result[$i].fullyqualifieddomainname; 
	#Write-host "----------------------------";
	
	$server_name = $server_result[$i].servername
	$rg_name = $server_result[$i].resourcegroupname; 
	$server_fqdn = $server_result[$i].fullyqualifieddomainname;
	
	
	if ($ServerAccountPwd.$server_name -eq $null)
	{
		Write-host "no password information, skip the server:$server_name";
    Write-host "----------------------------";
		continue
	}
	else
	{
		Write-host "has account and password information";
	}
	
  # store the server account and password info
	$server_admin = $ServerAccountPwd.$server_name.Username
	$server_admin_pwd = $ServerAccountPwd.$server_name.Password
	
  # get a list of databases other than master db in the server
	$database_list = Get-AzSqlDatabase -ServerName $server_name -ResourceGroupName $rg_name
	
  # for each database other than master, we run the VA query and set the result as new baseline
	For ($j = 0; $j -lt $database_list.count; $j++) 
	{
		$database_name = $database_list[$j].databasename
		if($database_name -eq 'master')
		{continue}
		Write-host $database_name;
		
    # prepare the parameters for executing query
		$params = @{'Database' = $database_name; 'ServerInstance' =  $server_fqdn; 'Username' = $server_admin; 'Password' = $server_admin_pwd; 'OutputSqlErrors' = $true;
		'Query' = $baseline_query }
		
    # execute query and store result
		$query_result = Invoke-Sqlcmd  @params
		Start-Sleep -s 2
		Write-host $query_result.count
		
    # skip those datanases that have no result, meaning these databases have no need to set the baseline.
		if( ($query_result.count -gt 0)) # -and ($database_name -eq 'Database1') )
		{
			$arrayList = [System.Collections.ArrayList]::new()
			For ($k = 0; $k -lt $query_result.count; $k++)
			{
				Write-host $query_result[$k].Owner;
				$arrayList.Add(@($query_result[$k].Owner))			
			}
			#Write-host $query_result
			#Write-host $arrayList	
			Set-AzSqlDatabaseVulnerabilityAssessmentRuleBaseline -ResourceGroupName $rg_name -ServerName $server_name -DatabaseName $database_name -BaselineResult $arrayList -RuleID $rule_id
		}
	}
  #Write-host "----------------------------";
	
}