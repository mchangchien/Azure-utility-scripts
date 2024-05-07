## Author : Matt Changchien
## Email: matt.changchien@microsoft.com
##

# variables declaration
# Create a hashtable
$token_dictionary = @{
    "E3" = "ENVCHANGE"
    "AD" = "LOGINACK"
    "AA" = "ERROR"
    "AB" = "INFO"
    "FD" = "DONE"

}


# variables declaration
# Create a hashtable
$token_dictionary = @{
    "E3" = "ENVCHANGE"
    "AD" = "LOGINACK"
    "AA" = "ERROR"
    "AB" = "INFO"
    "FD" = "DONE"

}


# Define function to convert byte array to XML
function ConvertLittleToBigEndian {
    param (
        $array
    )


    # Initialize new array
    $newArray = @()

    # Loop through the original array with a step of 2
    for ($i = 0; $i -lt $array.Length; $i += 2) {
        # Concatenate two elements and add to the new array
        $newArray += $array[$i+1] + $array[$i]
    }

    return $newArray
}





# Define function to convert byte array to XML
function ConvertHexArrayToPlaintext {
    param (
        $array
    )


    # Initialize new array
    $text

    # Loop through the original array with a step of 2
    foreach ($element in $array)  {
        # Concatenate two elements and add to the new array
        $text += [char]([Convert]::ToInt32($element, 16))
    }

    return $text
}


function printOutDict {
    param ($myDictionary)

    foreach ($key in $myDictionary.Keys) {
        $value = $myDictionary[$key]
        Write-Host "$key : $value"
    }

}



# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLENVCHANGE {
    param (
        [string[]]$str_arr
    )

    # variables declaration
    # Create a hashtable
$ENVCHANGE_type_dict = @{
    1 = "Database"
    2 = "Language"
    3 = "Character set"
    4 = "Packet size"
    5 = "Unicode data sorting local id"
    6 = "Unicode data sorting comparison flags"
    7 = "SQL Collation"
    8 = "Begin Transaction"
    9 = "Commit Transaction"
    10 = "Rollback Transaction"
    11 = "Enlist DTC Transaction"
    12 = "Defect Transaction"
    13 = "Real Time Log Shipping"
    15 = "Promote Transaction"
    16 = "Transaction Manager Address<47>"
    17 = "Transaction ended"
    18 = "RESETCONNECTION/RESETCONNECTIONSKIPTRAN Completion Acknowledgement"
    19 = "Sends back name of user instance started per login request"
    20 = "Sends routing information to client"
}


    # Start with token general information
    $tokenType = $($str_arr[0])
    $tokenLength = $($str_arr[1..2] | ForEach-Object { $_ })
    $EnvValData = $($str_arr[3])


    $EnvValData_dec = ([Convert]::ToInt32(($EnvValData).Replace(" ", ""), 16))

    # new value length multiplier is either 1 or 2 depending on it's B_VARCHAR or B_VARBYTE
    # And whether it's B_VARCHAR or B_VARBYTE depending on ENVCHANGE type described on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
    # 
    $newValueLengthMultiplier = 2
    $oldValueLengthMultiplier = 2
    switch ($EnvValData_dec) {
        5 {
            $oldValueLengthMultiplier = 0
        }
        6 {
            $oldValueLengthMultiplier = 0
        }
        7 {
            $newValueLengthMultiplier = 1
            $oldValueLengthMultiplier = 1
        }
        8 {
            $newValueLengthMultiplier = 1
            $oldValueLengthMultiplier = 0
        }
        9 {
            $newValueLengthMultiplier = 0
            $oldValueLengthMultiplier = 1
        }
        10 {
            $newValueLengthMultiplier = 0
            $oldValueLengthMultiplier = 1
        }
        11 {
            $newValueLengthMultiplier = 0
            $oldValueLengthMultiplier = 1
        }
        12 {
            $newValueLengthMultiplier = 1
            $oldValueLengthMultiplier = 0
        }
        13 {
            $newValueLengthMultiplier = 0  # TO DO: not sure what multiplier I should use for this
            $oldValueLengthMultiplier = 0 
        }
        15 {
            $newValueLengthMultiplier = 0  # TO DO: not sure what multiplier I should use for this
            $oldValueLengthMultiplier = 0
        }
        16 {
            $newValueLengthMultiplier = 0  # TO DO: not sure what multiplier I should use for this
            $oldValueLengthMultiplier = 0
        }
        17 {
            $newValueLengthMultiplier = 0  
            $oldValueLengthMultiplier = 1
        }
        18 {
            $newValueLengthMultiplier = 0
            $oldValueLengthMultiplier = 0
        }
        19 {
            $oldValueLengthMultiplier = 0
        }
        20 {
            $newValueLengthMultiplier = 0  # TO DO: not sure what multiplier I should use for this
            $oldValueLengthMultiplier = 0  # TO DO: not sure what multiplier I should use for this
        }
    }



    # deal with ENVCHANGE token data
    $newValOffset = 5
    $newValLength_dec = [Convert]::ToInt32(($str_arr[$newValOffset-1]).Replace(" ", ""), 16)
    $oldValOffset = $newValOffset+$newValLength_dec*$newValueLengthMultiplier+1  # add 1 means skipping the byte of BYTELEN
    $oldValLength_dec = [Convert]::ToInt32(($str_arr[$oldValOffset-1]).Replace(" ", ""), 16)

    

    $newValueLen = $($str_arr[$newValOffset-1])

    # if value length is 0, then that means the value is empty string
    if ($newValLength_dec -eq 0) {
        $newValueByte = ""
    }
    else {
        $newValueByte = $($str_arr[$newValOffset..($newValOffset+$newValLength_dec*$newValueLengthMultiplier-1)] | ForEach-Object { $_ })
    }

    $oldValueLen = $($str_arr[$oldValOffset-1])

    # if value length is 0, then that means the value is empty string
    if ($oldValLength_dec -eq 0) {
        $oldValueByte = ""
    }
    else {
        $oldValueByte = $($str_arr[$oldValOffset..($oldValOffset+$oldValLength_dec*$oldValueLengthMultiplier-1)] | ForEach-Object { $_ }) 
    }

   

    $ENVCHANGE = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "TOKEN Length" = [Convert]::ToInt32(($str_arr[2]+$str_arr[1]).Replace(" ", ""), 16)
        "ENVCHANGE DATA TYPE" = $ENVCHANGE_type_dict[$EnvValData_dec]
        "New Value Length" = [Convert]::ToInt32(($newValueLen).Replace(" ", ""), 16)
        "New Value" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $newValueByte)
        "Old Value Length" = [Convert]::ToInt32(($oldValueLen).Replace(" ", ""), 16)
        "Old Value" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $oldValueByte)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $ENVCHANGE
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
if ($EnvValData_dec -eq 7) {
    $xml = @"
<ENVCHANGE>
    <TokenType>
        <BYTE>$tokenType</BYTE>
    </TokenType>
    <Length>
        <USHORT>$tokenLength</USHORT>
    </Length>
    <EnvValueData>
        <Type>
            <BYTE>$EnvValData</BYTE>
        </Type>
        <NewValue>
            <B_VARBYTE>
                <BYTELEN>
                    <BYTE>$newValueLen</BYTE>
                </BYTELEN>
                <BYTES>$newValueByte</BYTES>
            </B_VARBYTE>
        </NewValue>
        <OldValue>
            <B_VARBYTE>
                <BYTELEN>
                    <BYTE>$oldValueLen</BYTE>
                </BYTELEN>
                <BYTES>$oldValueByte</BYTES>
            </B_VARBYTE>
        </OldValue>
    </EnvValueData>
</ENVCHANGE>
"@
} else {
    $xml = @"
<ENVCHANGE>
    <TokenType>
        <BYTE>$tokenType</BYTE>
    </TokenType>
    <Length>
        <USHORT>$tokenLength</USHORT>
    </Length>
    <EnvValueData>
        <Type>
            <BYTE>$EnvValData</BYTE>
        </Type>
        <NewValue>
            <B_VARCHAR>
                <BYTELEN>
                    <BYTE>$newValueLen</BYTE>
                </BYTELEN>
                <BYTES>$newValueByte</BYTES>
            </B_VARCHAR>
        </NewValue>
        <OldValue>
            <B_VARCHAR>
                <BYTELEN>
                    <BYTE>$oldValueLen</BYTE>
                </BYTELEN>
                <BYTES>$oldValueByte</BYTES>
            </B_VARCHAR>
        </OldValue>
    </EnvValueData>
</ENVCHANGE>
"@
}


   # Write-Host $xml
}




# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLLOGINACK {
    param (
        [string[]]$str_arr
    )


    # variables declaration
    # Create a hashtable
$LOGINACK_INTERFACE_dict = @{
    0 = "SQL_DFLT"
    1 = "SQL_TSQL"
}

    # Start with token general information
    $tokenType = $($str_arr[0])
    $tokenLength = $($str_arr[1..2] | ForEach-Object { $_ })
    $Interface = $($str_arr[3])
    $TDSVersion = $($str_arr[4..7] | ForEach-Object { $_ } )
    $Interface_dec = [Convert]::ToInt32($Interface.Replace(" ", ""), 16)

    
    # deal with LOGINACK token data
    $progNameLength = $($str_arr[8])
    $progNameLength_dec = [Convert]::ToInt32($str_arr[8].Replace(" ", ""), 16)

    # if value length is 0, then that means the value is empty string
    if ($progNameLength_dec -eq 0) {
        $progNameData = ""
    }
    else {
        $progNameData = $($str_arr[9..(9+$progNameLength_dec*2-1)] | ForEach-Object { $_ })
    }

    $progVer = $($str_arr[(9+$progNameLength_dec*2)..($str_arr.Length-1)] | ForEach-Object { $_ })
        
   
    # form the LOGINACK hash table with decoded info
    # more info on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/490e563d-cc6e-4c86-bb95-ef0186b98032
    $LOGINACK = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "TOKEN Length" = [Convert]::ToInt32(($str_arr[2]+$str_arr[1]).Replace(" ", ""), 16)
        "TDS Version" = "0x"+($TDSVersion -join '')
        "progName Length" = $progNameLength_dec
        "Interface" = $LOGINACK_INTERFACE_dict[$Interface_dec]
        "progNamee" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $progNameData)
        "MajorVer" = [Convert]::ToInt32(($progVer[0]).Replace(" ", ""), 16)
        "MinorVer" = [Convert]::ToInt32(($progVer[1]).Replace(" ", ""), 16)
        "BuildNumHi" = [Convert]::ToInt32(($progVer[2]).Replace(" ", ""), 16)
        "BuildNumLow" = [Convert]::ToInt32(($progVer[3]).Replace(" ", ""), 16)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $LOGINACK
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
$xml = @"
<LOGINACK>
    <TokenType>
        <BYTE>$tokenType </BYTE>
    </TokenType>
    <Length>
        <USHORT>$tokenLength </USHORT>
    </Length>
    <Interface>
        <BYTE>$Interface </BYTE>
    </Interface>
    <TDSVersion>
        <DWORD>$TDSVersion </DWORD>
    </TDSVersion>
    <ProgName>
        <B_VARCHAR>
            <BYTELEN>
                <BYTE>$progNameLength </BYTE>
            </BYTELEN>
            <BYTES>$progNameData </BYTES>
        </B_VARCHAR>
    </ProgName>
    <ProgVersion>
        <DWORD>$progVer </DWORD>
    </ProgVersion>
</LOGINACK>
"@

   # Write-Host $xml
}



# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLINFO {
    param (
        [string[]]$str_arr
    )



    # Start with token general information
    $tokenType = $($str_arr[0])
    $tokenLength = $($str_arr[1..2] | ForEach-Object { $_ })
    $number = $($str_arr[3..6] | ForEach-Object { $_ } )
    $number_reverse = $($str_arr[6..3] | ForEach-Object { $_ } )
    $state = $($str_arr[7])
    $class = $($str_arr[8])

    
    # deal with INFO token data

    
    # calculate the offsets and lengths of MSgText and ServerName and ProcName
    # also calculate the offset for LineNumber
    $MsgText_offset = 11
    $MsgTextLength = $($str_arr[9..10] | ForEach-Object { $_ } )
    $MsgTextLength_dec = [Convert]::ToInt32(($MsgTextLength[1]+$MsgTextLength[0]).Replace(" ", ""), 16)
    $serverName_Offset = $MsgText_offset+$MsgTextLength_dec*2+1   # +1 byte to skip the BYTELEN position
    $serverNameLength = $($str_arr[$MsgText_offset+$MsgTextLength_dec*2])
    $serverNameLength_dec = [Convert]::ToInt32(($serverNameLength), 16)
    $procName_Offset = $serverName_Offset+$serverNameLength_dec*2+1   # +1 byte to skip the BYTELEN position
    $procNameLength = $($str_arr[$serverName_Offset+$serverNameLength_dec*2])
    $procNameLength_dec = [Convert]::ToInt32(($procNameLength), 16)
    $lineNumber_Offset = $procName_Offset+$procNameLength_dec*2+1


    # get the data for MSgText and ServerName and ProcName
    # if value length is 0, then that means the value is empty string
    if ($MsgTextLength_dec -eq 0) {
        $MsgTextData = ""
    }
    else {
        $MsgTextData = $($str_arr[$MsgText_offset..($MsgText_offset+$MsgTextLength_dec*2-1)] | ForEach-Object { $_ })
    }

    # if value length is 0, then that means the value is empty string
    if ($serverNameLength_dec -eq 0) {
        $serverNameData = ""
    }
    else {
        $serverNameData = $($str_arr[$serverName_Offset..($serverName_Offset+$serverNameLength_dec*2-1)] | ForEach-Object { $_ })
    }

    # if value length is 0, then that means the value is empty string
    if ($procNameLength_dec -eq 0) {
        $procNameData = ""
    }
    else {
        $procNameData = $($str_arr[$procName_Offset..($procName_Offset+$procNameLength_dec*2-1)] | ForEach-Object { $_ })
    }

    $lineNumber = $($str_arr[$lineNumber_Offset..($str_arr.Length-1)] | ForEach-Object { $_ })
    $lineNumber_reverse = $($str_arr[($str_arr.Length-1)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes
   

    # form the LOGINACK hash table with decoded info
    # more info on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/490e563d-cc6e-4c86-bb95-ef0186b98032
    $INFO = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "TOKEN Length" = [Convert]::ToInt32(($str_arr[2]+$str_arr[1]).Replace(" ", ""), 16)
        "Number" = [Convert]::ToInt32((($number_reverse -join '')).Replace(" ", ""), 16)
        "State" = [Convert]::ToInt32(($state).Replace(" ", ""), 16)
        "Class" = [Convert]::ToInt32(($class).Replace(" ", ""), 16)
        "Message Text Length" = $MsgTextLength_dec
        "Message Text" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $MsgTextData)
        "Server Name Length" = $serverNameLength_dec
        "Server Name" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $serverNameData)
        "Proc Name Length" = $procNameLength_dec
        "Proc Name" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $procNameData)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $INFO
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
$xml = @"
<INFO>
    <TokenType>
        <BYTE>$tokenType </BYTE>
    </TokenType>
    <Length>
        <USHORT>$tokenLength </USHORT>
    </Length>
    <Number>
        <LONG>$number </LONG>
    </Number>
    <State>
        <BYTE>$state </BYTE>
    </State>
    <Class>
        <BYTE>$class </BYTE>
    </Class>
    <MsgText>
        <US_VARCHAR>
            <USHORTLEN>
                <USHORT>$MsgTextLength </USHORT>
            </USHORTLEN>
            <BYTES>$MsgTextData </BYTES>
        </US_VARCHAR>
    </MsgText>
    <ServerName>
        <B_VARCHAR>
            <BYTELEN>
                <BYTE>$serverNameLength </BYTE>
            </BYTELEN>
            <BYTES>$serverNameData</BYTES>
        </B_VARCHAR>
    </ServerName>
    <ProcName>
        <B_VARCHAR>
            <BYTELEN>
                <BYTE>$procNameLength </BYTE>
            </BYTELEN>
            <BYTES>$procNameData</BYTES>
        </B_VARCHAR>
    </ProcName>
    <LineNumber>
        <LONG>$lineNumber </LONG>
    </LineNumber>
</INFO>
"@

   # Write-Host $xml
}








# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLERROR {
    param (
        [string[]]$str_arr
    )

    # variables declaration
    # Create a hashtable
$ERROR_class_dict = @{
    0 = "Informational messages that return status information or report errors that are not severe."
    1 = "Informational messages that return status information or report errors that are not severe."
    2 = "Informational messages that return status information or report errors that are not severe."
    3 = "Informational messages that return status information or report errors that are not severe."
    4 = "Informational messages that return status information or report errors that are not severe."
    5 = "Informational messages that return status information or report errors that are not severe."
    6 = "Informational messages that return status information or report errors that are not severe."
    7 = "Informational messages that return status information or report errors that are not severe."
    8 = "Informational messages that return status information or report errors that are not severe."
    9 = "Informational messages that return status information or report errors that are not severe."
    10 = "Informational messages that return status information or report errors that are not severe."
    # "11-16" = "Errors that can be corrected by the user."
    11 = "The given object or entity does not exist."
    12 = "A special severity for SQL statements that do not use locking because of special options. In some cases, read operations performed by these SQL statements could result in inconsistent data, because locks are not taken to guarantee consistency."
    13 = "Transaction deadlock errors."
    14 = "Security-related errors, such as permission denied."
    15 = "Syntax errors in the SQL statement."
    16 = "General errors that can be corrected by the user."
    #"17-19" = "Software errors that cannot be corrected by the user. These errors require system administrator action."
    17 = "The SQL statement caused the database server to run out of resources (such as memory, locks, or disk space for the database) or to exceed some limit set by the system administrator."
    18 = "There is a problem in the Database Engine software, but the SQL statement completes execution, and the connection to the instance of the Database Engine is maintained. System administrator action is required."
    19 = "A non-configurable Database Engine limit has been exceeded and the current SQL batch has been terminated. Error messages with a severity level of 19 or higher stop the execution of the current SQL batch. Severity level 19 errors are rare and can be corrected only by the system administrator. Error messages with a severity level from 19 through 25 are written to the error log."
    #"20-25" = "System problems have occurred. These are fatal errors, which means the Database Engine task that was executing a SQL batch is no longer running. The task records information about what occurred and then terminates. In most cases, the application connection to the instance of the Database Engine can also terminate. If this happens, depending on the problem, the application might not be able to reconnect. Error messages in this range can affect all of the processes accessing data in the same database and might indicate that a database or object is damaged. Error messages with a severity level from 19 through 25 are written to the error log."
    20 = "Indicates that a SQL statement has encountered a problem. Because the problem has affected only the current task, it is unlikely that the database itself has been damaged."
    21 = "Indicates that a problem has been encountered that affects all tasks in the current database, but it is unlikely that the database itself has been damaged."
    22 = "Indicates that the table or index specified in the message has been damaged by a software or hardware problem. Severity level 22 errors occur rarely. If one occurs, run DBCC CHECKDB to determine whether other objects in the database are also damaged. The problem might be in the buffer cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, restoration of the database might be required. If restarting the instance of the Database Engine does not correct the problem, then the problem is on the disk. Sometimes destroying the object specified in the error message can solve the problem. For example, if the message reports that the instance of the Database Engine has found a row with a length of 0 in a non-clustered index, delete the index and rebuild it."
    23 = "Indicates that the integrity of the entire database is in question because of a hardware or software problem. Severity level 23 errors occur rarely. If one occurs, run DBCC CHECKDB to determine the extent of the damage. The problem might be in the cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, restoration of the database might be required."
    24 = "Indicates a media failure. The system administrator might have to restore the database or resolve a hardware issue."
}

    # Start with token general information
    $tokenType = $($str_arr[0])
    $tokenLength = $($str_arr[1..2] | ForEach-Object { $_ })
    $number = $($str_arr[3..6] | ForEach-Object { $_ } )
    $number_reverse = $($str_arr[6..3] | ForEach-Object { $_ } )
    $state = $($str_arr[7])
    $class = $($str_arr[8])
    $class_dec = [Convert]::ToInt32(($class).Replace(" ", ""), 16)
    
    # deal with INFO token data

    
    # calculate the offsets and lengths of MSgText and ServerName and ProcName
    # also calculate the offset for LineNumber
    $MsgText_offset = 11
    $MsgTextLength = $($str_arr[9..10] | ForEach-Object { $_ } )
    $MsgTextLength_dec = [Convert]::ToInt32(($MsgTextLength[1]+$MsgTextLength[0]).Replace(" ", ""), 16)
    $serverName_Offset = $MsgText_offset+$MsgTextLength_dec*2+1   # +1 byte to skip the BYTELEN position
    $serverNameLength = $($str_arr[$MsgText_offset+$MsgTextLength_dec*2])
    $serverNameLength_dec = [Convert]::ToInt32(($serverNameLength), 16)
    $procName_Offset = $serverName_Offset+$serverNameLength_dec*2+1   # +1 byte to skip the BYTELEN position
    $procNameLength = $($str_arr[$serverName_Offset+$serverNameLength_dec*2])
    $procNameLength_dec = [Convert]::ToInt32(($procNameLength), 16)
    $lineNumber_Offset = $procName_Offset+$procNameLength_dec*2+1


    # get the data for MSgText and ServerName and ProcName
    # if value length is 0, then that means the value is empty string
    if ($MsgTextLength_dec -eq 0) {
        $MsgTextData = ""
    }
    else {
        $MsgTextData = $($str_arr[$MsgText_offset..($MsgText_offset+$MsgTextLength_dec*2-1)] | ForEach-Object { $_ })
    }

    # if value length is 0, then that means the value is empty string
    if ($serverNameLength_dec -eq 0) {
        $serverNameData = ""
    }
    else {
        $serverNameData = $($str_arr[$serverName_Offset..($serverName_Offset+$serverNameLength_dec*2-1)] | ForEach-Object { $_ })
    }

    # if value length is 0, then that means the value is empty string
    if ($procNameLength_dec -eq 0) {
        $procNameData = ""
    }
    else {
        $procNameData = $($str_arr[$procName_Offset..($procName_Offset+$procNameLength_dec*2-1)] | ForEach-Object { $_ })
    }

    $lineNumber = $($str_arr[$lineNumber_Offset..($str_arr.Length-1)] | ForEach-Object { $_ })
    $lineNumber_reverse = $($str_arr[($str_arr.Length-1)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes
   

    # form the LOGINACK hash table with decoded info
    # more info on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/490e563d-cc6e-4c86-bb95-ef0186b98032
    $ERROR = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "TOKEN Length" = [Convert]::ToInt32(($str_arr[2]+$str_arr[1]).Replace(" ", ""), 16)
        "Number" = [Convert]::ToInt32((($number_reverse -join '')).Replace(" ", ""), 16)
        "State" = [Convert]::ToInt32(($state).Replace(" ", ""), 16)
        "Class" = ERROR_class_dict[$class_dec]
        "Message Text Length" = $MsgTextLength_dec
        "Message Text" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $MsgTextData)
        "Server Name Length" = $serverNameLength_dec
        "Server Name" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $serverNameData)
        "Proc Name Length" = $procNameLength_dec
        "Proc Name" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $procNameData)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $ERROR
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
$xml = @"
<ERROR>
    <TokenType>
        <BYTE>$tokenType </BYTE>
    </TokenType>
    <Length>
        <USHORT>$tokenLength </USHORT>
    </Length>
    <Number>
        <LONG>$number </LONG>
    </Number>
    <State>
        <BYTE>$state </BYTE>
    </State>
    <Class>
        <BYTE>$class </BYTE>
    </Class>
    <MsgText>
        <US_VARCHAR>
            <USHORTLEN>
                <USHORT>$MsgTextLength </USHORT>
            </USHORTLEN>
            <BYTES>$MsgTextData </BYTES>
        </US_VARCHAR>
    </MsgText>
    <ServerName>
        <B_VARCHAR>
            <BYTELEN>
                <BYTE>$serverNameLength </BYTE>
            </BYTELEN>
            <BYTES>$serverNameData</BYTES>
        </B_VARCHAR>
    </ServerName>
    <ProcName>
        <B_VARCHAR>
            <BYTELEN>
                <BYTE>$procNameLength </BYTE>
            </BYTELEN>
            <BYTES>$procNameData</BYTES>
        </B_VARCHAR>
    </ProcName>
    <LineNumber>
        <LONG>$lineNumber </LONG>
    </LineNumber>
</ERROR>
"@

   # Write-Host $xml
}







##------------------------------------------
##
## Main starts here
##
##------------------------------------------


# Prompt the user for input
$userInput = Read-Host -Prompt 'Please enter a string'

# Print the user's input
Write-Host "You entered: $userInput"

# Convert hexadecimal string to byte array
$str_arr = [string[]]($userInput -split '([0-9A-F]{2})' | Where-Object { $_ -ne '' })

#Write-Host $str_arr
Write-Host "--------------------------------------------------------------------------------"


# Loop through the original array with a step of 2
for ($i = 0; $i -lt $str_arr.Length; $i += 1) {
    switch ($str_arr[$i]) {
        "04" { 
         # packet header
         $i = $i+7 # fast forward to the last digit in the packet header 
        }

        "E3" {
            # dealing with ENV
            $str_env = @()

            Do{
                $str_env+=$str_arr[$i]
                $i+=1

            } While( ($null -ne $str_arr[$i]) -and ($null -eq $token_dictionary[$str_arr[$i]]))

            # we've done the looping, get 1 step back  
            $i-=1

            # we've got the complete ENVCHANGE data, throw it into function to process
            ConvertToXMLENVCHANGE $str_env

        }

        "AD" {
            # dealing with LOGINACK
            $str_logack = @()

            Do{
                $str_logack+=$str_arr[$i]
                $i+=1

            } While( ($null -ne $str_arr[$i]) -and ($null -eq $token_dictionary[$str_arr[$i]]))

            # we've done the looping, get 1 step back  
            $i-=1

            # we've got the complete ENVCHANGE data, throw it into function to process
            ConvertToXMLLOGINACK $str_logack
        }

        "AB" {
            # dealing with LOGINACK
            $str_info = @()

            Do{
                $str_info+=$str_arr[$i]
                $i+=1

            } While( ($null -ne $str_arr[$i]) -and ($null -eq $token_dictionary[$str_arr[$i]]))

            # we've done the looping, get 1 step back  
            $i-=1

            # we've got the complete ENVCHANGE data, throw it into function to process
            ConvertToXMLINFO $str_info
        }

    }


}



# end of the script















