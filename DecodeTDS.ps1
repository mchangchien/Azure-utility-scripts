## Author : Matt Changchien
## Email: matt.changchien@microsoft.com
##






###################################################################

# Global parameters section

###################################################################


# variables declaration
# Create a hashtable
$token_dictionary = @{
    "E3" = "ENVCHANGE"
    "AD" = "LOGINACK"
    "AA" = "ERROR"
    "AB" = "INFO"
    "FD" = "DONE"
    "81" = "COLMETADATA"

}






###################################################################

# Utiliy Functions section

###################################################################


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
            return ConvertToXMLENVCHANGERoute $str_arr            
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
        $lastindex = $oldValOffset-1
    }
    else {
        $oldValueByte = $($str_arr[$oldValOffset..($oldValOffset+$oldValLength_dec*$oldValueLengthMultiplier-1)] | ForEach-Object { $_ }) 
        $lastindex = ($oldValOffset+$oldValLength_dec*$oldValueLengthMultiplier-1)
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

     return $lastindex 
   # Write-Host $xml
}


# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLENVCHANGERoute {
    param (
        [string[]]$str_arr
    )
    
    # Start with token general information
    $tokenType = $($str_arr[0])
    $tokenLength = $($str_arr[1..2] | ForEach-Object { $_ })
    $EnvValData = $($str_arr[3])

    # deal with ENVCHANGE token data
    $newValOffset = 4+2 # because in env type 20, the length (RoutingDataValueLength) takes 2 bytes (USHORT)
    $newValLength = $($str_arr[4..5] | ForEach-Object { $_ })
    $newValLength_dec = [Convert]::ToInt32(($str_arr[5]+$str_arr[4]).Replace(" ", ""), 16)
    $oldValOffset = $newValOffset+$newValLength_dec 
    $oldValLength_dec = 2 # it's fixed in env type 20 "Sends routing information to client"

    $lastindex = $oldValOffset+2 # add 2 bytes of oldvalue and minus on
    

    # if value length is 0, then that means the value is empty string
    if ($newValLength_dec -eq 0) {
        $newValueByte = ""
        $protocalValue = "" # protocoal takes 1 byte and it's at the start of the new value
        $protocalPropertiesValue = ""
        $alternateServerLength = ""
        $alternateServerLength_dec = ""
        $alternateServerValue = ""
    }
    else {
        $newValueByte = $($str_arr[$newValOffset..($newValOffset+$newValLength_dec*$newValueLengthMultiplier-1)] | ForEach-Object { $_ })
        $protocalValue = $($str_arr[$newValOffset]) # protocoal takes 1 byte and it's at the start of the new value
        $protocalValue_dec = [Convert]::ToInt32(($protocalValue), 16)
        $protocalPropertiesValue = $($str_arr[($newValOffset+1)..($newValOffset+2)])
        $protocalPropertiesValue_dec = [Convert]::ToInt32(($str_arr[($newValOffset+2)]+$str_arr[($newValOffset+1)]).Replace(" ", ""), 16)
        $alternateServerLength = $($str_arr[($newValOffset+3)..($newValOffset+4)])
        $alternateServerLength_dec = [Convert]::ToInt32(($str_arr[$newValOffset+4]+$str_arr[$newValOffset+3]).Replace(" ", ""), 16)
        $alternateServerValue = $($str_arr[($newValOffset+5)..($newValOffset+5+$alternateServerLength_dec*2-1)] | ForEach-Object { $_ })
        
        # according to https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
        # Protocol MUST be 0, specifying TCP-IP protocol. 
        # ProtocolProperty represents the TCP-IP port when Protocol is 0. A ProtocolProperty value of zero is not allowed when Protocol is TCP-IP.
        if ($protocalValue_dec -eq 0)
        {
          $protocalValueText = "TCP/IP"
        }
        else
        {
          $protocalValueText = "Unrecognized Protocol"
        }
    }
   

    $ENVCHANGEROUTE = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "TOKEN Length" = [Convert]::ToInt32(($str_arr[2]+$str_arr[1]).Replace(" ", ""), 16)
        "ENVCHANGE DATA TYPE" = "Sends routing information to client"
        "New Value Length" = $newValLength_dec
        "New Value" = "N/A"
        "Protocol" = $protocalValueText
        "Port Number" = $protocalPropertiesValue_dec
        "Alternate Server (Route to this server)" = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $alternateServerValue)
        "Old Value Length" = $oldValLength_dec
        "Old Value" = "00 00"
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $ENVCHANGEROUTE
    Write-Host "--------------------------------------------------------------------------------"


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
            <RoutingDataValueLength>
                <USHORT>$newValLength</USHORT>
            </RoutingDataValueLength>
            <RoutingDataValue>
                <Protocol>$protocalValue</Protocol>
                <ProtocolProperty>$protocalPropertiesValue</ProtocolProperty>
                <AlternateServer>
                    <US_VARCHAR>
                        <USHORTLEN>
                            <USHORT>$alternateServerLength </USHORT>
                        </USHORTLEN>
                        <BYTES>$alternateServerValue </BYTES>
                    </US_VARCHAR>
                </AlternateServer>
            </RoutingDataValue>
        </NewValue>
        <OldValue>00 00</OldValue>
    </EnvValueData>
</ENVCHANGE>
"@


     return $lastindex 
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


    # progVer contains 4 bytes information(MajorVer, MinorVer, BuildNumHi, BuildNumLow)
    $progVer = $($str_arr[(9+$progNameLength_dec*2)..(9+$progNameLength_dec*2+3)] | ForEach-Object { $_ })
    $lastindex = (9+$progNameLength_dec*2+3)
   
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
   return $lastindex
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
    $lineNumber_Offset = $procName_Offset+$procNameLength_dec*2 # NO Need +1 byte to skip the BYTELEN position


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

    
    # LineNumber is LONG(has 4 bytes) after TDS 7.2, is USHORT(2 bytes) prior to TDS 7.2
    # since we cannot determine the TDS version here, check the the thrid byte of the LineNumber if it's not a token type
    # then that means LineNumber likely has 4 bytes(LONG)
    if ($null -eq $token_dictionary[$str_arr[$lineNumber_Offset+2]])
    {
        $lineNumber = $($str_arr[$lineNumber_Offset..($lineNumber_Offset+3)] | ForEach-Object { $_ })
        $lineNumber_reverse = $($str_arr[($lineNumber_Offset+3)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes   
        $lastindex = ($lineNumber_Offset+3)
    }
    else
    {
        $lineNumber = $($str_arr[$lineNumber_Offset..($lineNumber_Offset+1)] | ForEach-Object { $_ })
        $lineNumber_reverse = $($str_arr[($lineNumber_Offset+1)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes   
        $lastindex = ($lineNumber_Offset+1)
    }



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
   return $lastindex
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
    $lineNumber_Offset = $procName_Offset+$procNameLength_dec*2 # NO Need +1 byte to skip the BYTELEN position


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

    # LineNumber is LONG(has 4 bytes) after TDS 7.2, is USHORT(2 bytes) prior to TDS 7.2
    # since we cannot determine the TDS version here, check the the thrid byte of the LineNumber if it's not a token type
    # then that means LineNumber likely has 4 bytes(LONG)
    if ($null -eq $token_dictionary[$str_arr[$lineNumber_Offset+2]])
    {
        $lineNumber = $($str_arr[$lineNumber_Offset..($lineNumber_Offset+3)] | ForEach-Object { $_ })
        $lineNumber_reverse = $($str_arr[($lineNumber_Offset+3)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes   
        $lastindex = ($lineNumber_Offset+3)
    }
    else
    {
        $lineNumber = $($str_arr[$lineNumber_Offset..($lineNumber_Offset+1)] | ForEach-Object { $_ })
        $lineNumber_reverse = $($str_arr[($lineNumber_Offset+1)..$lineNumber_Offset] | ForEach-Object { $_ })   #Little Endian to Big Endian by reverse the bytes   
        $lastindex = ($lineNumber_Offset+1)
    }

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

    return $lastindex
   # Write-Host $xml
}




# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function ConvertToXMLDONE {
    param (
        [string[]]$str_arr
    )

# mapping Status according to https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/3c06f110-98bd-4d5b-b836-b1ba66452cb7
$Done_status_dict = @{
    ([Convert]::ToInt32(0, 16)) = "DONE_FINAL. This DONE is the final DONE in the request."
    ([Convert]::ToInt32(1, 16)) = "DONE_MORE. This DONE message is not the final DONE message in the response. Subsequent data streams to follow."
    ([Convert]::ToInt32(2, 16)) = "DONE_ERROR. An error occurred on the current SQL statement. A preceding ERROR token SHOULD be sent when this bit is set."
    ([Convert]::ToInt32(4, 16)) = "DONE_INXACT. A transaction is in progress.<43>"
    ([Convert]::ToInt32(10, 16)) = "DONE_COUNT. The DoneRowCount value is valid. This is used to distinguish between a valid value of 0 for DoneRowCount or just an initialized variable."
    ([Convert]::ToInt32(20, 16)) = "DONE_ATTN. The DONE message is a server acknowledgement of a client ATTENTION message."
    ([Convert]::ToInt32(100, 16)) = "DONE_SRVERROR. Used in place of DONE_ERROR when an error occurred on the current SQL statement, which is severe enough to require the result set, if any, to be discarded."
}

    # Start with token general information
    $tokenType = $($str_arr[0])
    $status = $($str_arr[1..2] | ForEach-Object { $_ })
    $status_reverse = $($str_arr[2..1] | ForEach-Object { $_ })
    $curCmd = $($str_arr[3..4] | ForEach-Object { $_ } )
    $curCmd_reverse = $($str_arr[4..3] | ForEach-Object { $_ } )


    # DoneRowCount is ULONGLONG (has 8 bytes) after TDS 7.2, is LONG (4 bytes) prior to TDS 7.2
    # since we cannot determine the TDS version here, check the the thrid byte of the DoneRowCount if it's not a token type
    # then that means DoneRowCount likely has 4 bytes(LONG)
    if ($null -eq $token_dictionary[$str_arr[9]])
    {
        $doneRowCount = $($str_arr[5..12] | ForEach-Object { $_ })
        $doneRowCount_reverse = $($str_arr[12..5] | ForEach-Object { $_ })
        $lastindex = 12
    }
    else
    {
        $doneRowCount = $($str_arr[5..8] | ForEach-Object { $_ })
        $doneRowCount_reverse = $($str_arr[8..5] | ForEach-Object { $_ })
        $lastindex = 8
    }



    # form the LOGINACK hash table with decoded info
    # more info on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/490e563d-cc6e-4c86-bb95-ef0186b98032
    $DONE = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "Status" = $Done_status_dict[[Convert]::ToInt32((($status_reverse -join '')).Replace(" ", ""), 16)]
        "Current SQL Statement" = [Convert]::ToInt32((($curCmd_reverse -join '')).Replace(" ", ""), 16)
        "Done Row Count" = [Convert]::ToInt32((($doneRowCount_reverse -join '')).Replace(" ", ""), 16)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $DONE
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
$xml = @"
<DONE>
    <TokenType>
        <BYTE>FD </BYTE>
    </TokenType>
    <Status>
        <USHORT>00 00 </USHORT>
    </Status>
    <CurCmd>
        <USHORT>00 00 </USHORT>
    </CurCmd>
    <DoneRowCount>
        <LONGLONG>00 00 00 00 00 00 00 00 </LONGLONG>
    </DoneRowCount>
</DONE>
"@
    
    return $lastindex
   # Write-Host $xml
}




# Define function to convert byte array to XML for COLMETADATA - some are put in reverse order because of Little Endian
function ConvertToXMLCOLMETADATA {
    param (
        [string[]]$str_arr
    )

# mapping Status according to https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/3c06f110-98bd-4d5b-b836-b1ba66452cb7
$Done_status_dict = @{
    ([Convert]::ToInt32(0, 16)) = "DONE_FINAL. This DONE is the final DONE in the request."
    ([Convert]::ToInt32(1, 16)) = "DONE_MORE. This DONE message is not the final DONE message in the response. Subsequent data streams to follow."
    ([Convert]::ToInt32(2, 16)) = "DONE_ERROR. An error occurred on the current SQL statement. A preceding ERROR token SHOULD be sent when this bit is set."
    ([Convert]::ToInt32(4, 16)) = "DONE_INXACT. A transaction is in progress.<43>"
    ([Convert]::ToInt32(10, 16)) = "DONE_COUNT. The DoneRowCount value is valid. This is used to distinguish between a valid value of 0 for DoneRowCount or just an initialized variable."
    ([Convert]::ToInt32(20, 16)) = "DONE_ATTN. The DONE message is a server acknowledgement of a client ATTENTION message."
    ([Convert]::ToInt32(100, 16)) = "DONE_SRVERROR. Used in place of DONE_ERROR when an error occurred on the current SQL statement, which is severe enough to require the result set, if any, to be discarded."
}

    # Start with token general information
    $tokenType = $($str_arr[0])
    $status = $($str_arr[1..2] | ForEach-Object { $_ })
    $status_reverse = $($str_arr[2..1] | ForEach-Object { $_ })
    $curCmd = $($str_arr[3..4] | ForEach-Object { $_ } )
    $curCmd_reverse = $($str_arr[4..3] | ForEach-Object { $_ } )


    # DoneRowCount is ULONGLONG (has 8 bytes) after TDS 7.2, is LONG (4 bytes) prior to TDS 7.2
    # since we cannot determine the TDS version here, check the the thrid byte of the DoneRowCount if it's not a token type
    # then that means DoneRowCount likely has 4 bytes(LONG)
    if ($null -eq $token_dictionary[$str_arr[9]])
    {
        $doneRowCount = $($str_arr[5..12] | ForEach-Object { $_ })
        $doneRowCount_reverse = $($str_arr[12..5] | ForEach-Object { $_ })
        $lastindex = 12
    }
    else
    {
        $doneRowCount = $($str_arr[5..8] | ForEach-Object { $_ })
        $doneRowCount_reverse = $($str_arr[8..5] | ForEach-Object { $_ })
        $lastindex = 8
    }



    # form the LOGINACK hash table with decoded info
    # more info on https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/490e563d-cc6e-4c86-bb95-ef0186b98032
    $COLMETADATA = @{
        "TOKEN TYPE" = $token_dictionary[$tokenType]
        "Status" = $Done_status_dict[[Convert]::ToInt32((($status_reverse -join '')).Replace(" ", ""), 16)]
        "Current SQL Statement" = [Convert]::ToInt32((($curCmd_reverse -join '')).Replace(" ", ""), 16)
        "Done Row Count" = [Convert]::ToInt32((($doneRowCount_reverse -join '')).Replace(" ", ""), 16)
    }

    Write-Host "--------------------------------------------------------------------------------"
    printOutDict $COLMETADATA
    Write-Host "--------------------------------------------------------------------------------"

# Different XML label/format depeneding on EnvValData type
# TO DO: soem types are not being dealt well here. 
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-tds/2b3eb7e5-d43d-4d1b-bf4d-76b9e3afc791
$xml = @"
<COLMETADATA>
    <TokenType>
        BYTE>81 </BYTE>
    </TokenType>
    <Count>
        <USHORT>01 00 </USHORT>
    </Count>
    <ColumnData>
        <UserType>
            <ULONG>00 00 00 00 </ULONG>
        </UserType>
        <Flags>
            <USHORT>20 00 </USHORT>
        </Flags>
        <TYPE_INFO>
            <VARLENTYPE>
                <USHORTLEN_TYPE>
                    <BYTE>A7 </BYTE>
                </USHORTLEN_TYPE>
            </VARLENTYPE>
            <TYPE_VARLEN>
                <USHORTCHARBINLEN>
                    <USHORT>03 00 </USHORT>
                </USHORTCHARBINLEN>
            </TYPE_VARLEN>
            <COLLATION>
                <BYTES>09 04 D0 00 34 </BYTES>
            </COLLATION>
        </TYPE_INFO>
        <ColName>
            <B_VARCHAR>
                <BYTELEN>
                    <BYTE>03 </BYTE>
                </BYTELEN>
                <BYTES ascii="b.a.r.">62 00 61 00 72 00 </BYTES>
            </B_VARCHAR>
        </ColName>
    </ColumnData>
</COLMETADATA>
"@
    
    return $lastindex
   # Write-Host $xml
}





# Define function to convert byte array to XML - some are put in reverse order because of Little Endian
function ConvertToXML123 {
    param (
        [string[]]$str_arr
    )



    $xml = @"
<root>
<PacketHeader>
    <Type>
        <BYTE>$($str_arr[0]) </BYTE>
    </Type>
    <Status>
        <BYTE>$($str_arr[1]) </BYTE>
    </Status>
    <Length>
        <BYTE>$($str_arr[2]) </BYTE>
        <BYTE>$($str_arr[3]) </BYTE>
    </Length>
    <SPID>
        <BYTE>$($str_arr[4]) </BYTE>
        <BYTE>$($str_arr[5]) </BYTE>
    </SPID>
    <PacketID>
        <BYTE>$($str_arr[6]) </BYTE>
    </PacketID>
    <Window>
        <BYTE>$($str_arr[7]) </BYTE>
    </Window>
</PacketHeader>
<PacketData>
    <LOGIN7>
        <Length>
            <DWORD>$($str_arr[11..8] | ForEach-Object { $_ }) </DWORD>
        </Length>
        <TDSVersion>
            <DWORD>$($str_arr[12..15] | ForEach-Object { $_ }) </DWORD>
        </TDSVersion>
        <PacketSize>
            <DWORD>$($str_arr[19..16] | ForEach-Object { $_ }) </DWORD>
        </PacketSize>
        <ClientProgVer>
            <DWORD>$($str_arr[20..23] | ForEach-Object { $_ }) </DWORD>
        </ClientProgVer>
        <ClientPID>
            <DWORD>$($str_arr[27..24] | ForEach-Object { $_ }) </DWORD>
        </ClientPID>
        <ConnectionID>
            <DWORD>$($str_arr[28..31] | ForEach-Object { $_ }) </DWORD>
        </ConnectionID>
        <OptionFlags1>
            <BYTE>$($str_arr[32]) </BYTE>
        </OptionFlags1>
        <OptionFlags2>
            <BYTE>$($str_arr[33]) </BYTE>
        </OptionFlags2>
        <TypeFlags>
            <BYTE>$($str_arr[34]) </BYTE>
        </TypeFlags>
        <OptionFlags3>
            <BYTE>$($str_arr[35]) </BYTE>
        </OptionFlags3>
        <ClientTimeZone>
            <LONG>$($str_arr[36..39] | ForEach-Object { $_ }) </LONG>
        </ClientTimeZone>
        <ClientLCID>
            <DWORD>$($str_arr[40..43] | ForEach-Object { $_ }) </DWORD>
        </ClientLCID>
        <OffsetLength>
            <ibHostName>
                <USHORT>$($str_arr[45..44] | ForEach-Object { $_ }) </USHORT>
            </ibHostName>
            <cchHostName>
                <USHORT>$($str_arr[47..46] | ForEach-Object { $_ }) </USHORT>
            </cchHostName>
            <ibUserName>
                <USHORT>$($str_arr[49..48] | ForEach-Object { $_ }) </USHORT>
            </ibUserName>
            <cchUserName>
                <USHORT>$($str_arr[51..50] | ForEach-Object { $_ }) </USHORT>
            </cchUserName>
            <ibPassword>
                <USHORT>$($str_arr[53..52] | ForEach-Object { $_ }) </USHORT>
            </ibPassword>
            <cchPassword>
                <USHORT>$($str_arr[55..54] | ForEach-Object { $_ }) </USHORT>
            </cchPassword>
            <ibAppName>
                <USHORT>$($str_arr[57..56] | ForEach-Object { $_ }) </USHORT>
            </ibAppName>
            <cchAppName>
                <USHORT>$($str_arr[59..58] | ForEach-Object { $_ }) </USHORT>
            </cchAppName>
            <ibServerName>
                <USHORT>$($str_arr[61..60] | ForEach-Object { $_ }) </USHORT>
            </ibServerName>
            <cchServerName>
                <USHORT>$($str_arr[63..62] | ForEach-Object { $_ }) </USHORT>
            </cchServerName>
            <ibUnused>
                <USHORT>$($str_arr[65..64] | ForEach-Object { $_ }) </USHORT>
            </ibUnused>
            <cbUnused>
                <USHORT>$($str_arr[67..66] | ForEach-Object { $_ }) </USHORT>
            </cbUnused>
            <ibCltIntName>
                <USHORT>$($str_arr[69..68] | ForEach-Object { $_ }) </USHORT>
            </ibCltIntName>
            <cchCltIntName>
                <USHORT>$($str_arr[71..70] | ForEach-Object { $_ }) </USHORT>
            </cchCltIntName>
            <ibLanguage>
                <USHORT>$($str_arr[73..72] | ForEach-Object { $_ }) </USHORT>
            </ibLanguage>
            <cchLanguage>
                <USHORT>$($str_arr[75..74] | ForEach-Object { $_ }) </USHORT>
            </cchLanguage>
            <ibDatabase>
                <USHORT>$($str_arr[77..76] | ForEach-Object { $_ }) </USHORT>
            </ibDatabase>
            <cchDatabase>
                <USHORT>$($str_arr[79..78] | ForEach-Object { $_ }) </USHORT>
            </cchDatabase>
            <ClientID>
                <str_arr>$($str_arr[85..80] | ForEach-Object { $_ }) </str_arr>
            </ClientID>
            <ibSSPI>
                <USHORT>$($str_arr[87..86] | ForEach-Object { $_ }) </USHORT>
            </ibSSPI>
            <cbSSPI>
                <USHORT>$($str_arr[89..88] | ForEach-Object { $_ }) </USHORT>
            </cbSSPI>
            <ibAtchDBFile>
                <USHORT>$($str_arr[91..90] | ForEach-Object { $_ }) </USHORT>
            </ibAtchDBFile>
            <cchAtchDBFile>
                <USHORT>$($str_arr[93..92] | ForEach-Object { $_ }) </USHORT>
            </cchAtchDBFile>
            <ibChangePassword>
                <USHORT>$($str_arr[95..94] | ForEach-Object { $_ }) </USHORT>
            </ibChangePassword>
            <cchChangePassword>
                <USHORT>$($str_arr[97..96] | ForEach-Object { $_ }) </USHORT>
            </cchChangePassword>
            <cbSSPILong>
                <LONG>$($str_arr[101..98] | ForEach-Object { $_ }) </LONG>
            </cbSSPILong>
        </OffsetLength>
        <Data>
            <str_arr>$($str_arr[102..$str_arr.Length] | ForEach-Object { $_ }) </str_arr>
        </Data>
    </LOGIN7>
</PacketData>
</root>
"@


    return $xml
}

# Define function to convert byte array to XML
function GetFieldValue {
    param (
        $array,
        $OffSet,
        $len
    )

    if ($len -eq 0) 
    {
        return "0000" # null in hex
    }
    else
    {
       return $str_arr[($OffSet+8)..($OffSet+8+$len*2-1)]
    }
}





# Define the main function
function PWDDecoder {
    param (
        $password
    )

    # Define the encoding hashtable
    $encoding = @{
        'b3'='a'; '83'='b'; '93'='c'; 'e3'='d'; 'f3'='e'; 'c3'='f'; 'd3'='g'; '23'='h'; '33'='i'; '03'='j';
        '13'='k'; '63'='l'; '73'='m'; '43'='n'; '53'='o'; 'a2'='p'; 'b2'='q'; '82'='r'; '92'='s'; 'e2'='t';
        'f2'='u'; 'c2'='v'; 'd2'='w'; '22'='x'; '32'='y'; '02'='z'; 'b1'='A'; '81'='B'; '91'='C'; 'e1'='D';
        'f1'='E'; 'c1'='F'; 'd1'='G'; '21'='H'; '31'='I'; '01'='J'; '11'='K'; '61'='L'; '71'='M'; '41'='N';
        '51'='O'; 'a0'='P'; 'b0'='Q'; '80'='R'; '90'='S'; 'e0'='T'; 'f0'='U'; 'c0'='V'; 'd0'='W'; '20'='X';
        '30'='Y'; '00'='Z'; 'b6'='1'; '86'='2'; '96'='3'; 'e6'='4'; 'f6'='5'; 'c6'='6'; 'd6'='7'; '26'='8';
        '36'='9'; 'a6'='0'; 'a7'=' '; 'b7'='!'; '87'='"'; 'd7'=''''; 'df'='§'; 'e7'='$'; 'f7'='%'; 'c7'='&';
        '57'='/'; '60'='\'; '27'='('; '37'=')'; '76'='='; '56'='?'; '77'='-'; '50'='_'; '17'='+'; 'a1'='@';
        '06'=':'; '16'=';'; '67'=', '; '47'='.'
    }

    try {
        # Get rid of delimiter
        $password = $password -replace 'a5', ''

        # Add to array and remove space
        $chars = $password -split ' ' | Where-Object { $_ }

        # Start decoding
        $decoded = ''
        foreach ($char in $chars) {
            $decoded += $encoding[$char]
        }

        #Write-Host "`nPassword is: $decoded`n"
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    
    return $decoded

}













###################################################################

# Handler Functions section

###################################################################




# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function TableResponseHandler {
    param (
        [string[]]$tableresponse_arr
    )
    # Loop through the original array with a step of 2
    for ($i = 0; $i -lt $tableresponse_arr.Length; $i += 1) {
        switch ($tableresponse_arr[$i]) {
            "04" { 
             # packet header
             $i = $i+7 # fast forward to the last digit in the packet header 
            }

            "E3" {
                # dealing with ENV

                # call function to process ENVCHANGE token and returns the last index of the token
                # set $i = $i + the last index of the token will be the last index of the current array we are currently at
                $i = $i+ (ConvertToXMLENVCHANGE $tableresponse_arr[$i..$str_arr.Length])
            }

            "AD" {
                # dealing with LOGINACK

                # call function to process ENVCHANGE token and returns the last index of the token
                # set $i = $i + the last index of the token will be the last index of the current array we are currently at
                $i = $i+ (ConvertToXMLLOGINACK $tableresponse_arr[$i..$str_arr.Length])
            }

            "AB" {
                # dealing with INFO

                # call function to process ENVCHANGE token and returns the last index of the token
                # set $i = $i + the last index of the token will be the last index of the current array we are currently at
                $i = $i+ (ConvertToXMLINFO $tableresponse_arr[$i..$str_arr.Length])
            }

            "AA" {
                # dealing with ERROR

                # call function to process ENVCHANGE token and returns the last index of the token
                # set $i = $i + the last index of the token will be the last index of the current array we are currently at
                $i = $i+ (ConvertToXMLERROR $tableresponse_arr[$i..$str_arr.Length])
            }

            "FD" {
                # dealing with DONE

                # call function to process ENVCHANGE token and returns the last index of the token
                # set $i = $i + the last index of the token will be the last index of the current array we are currently at
                $i = $i+ (ConvertToXMLDONE $tableresponse_arr[$i..$str_arr.Length])
            }
        }
    }
}



# Define function to convert byte array to XML for ENVCHANGE - some are put in reverse order because of Little Endian
function LoginRequestHandler {
    param (
        [string[]]$loginrequest_arr
    )

    # variables declaration
    # Create a hashtable
    $dictionary = @{}

    # Convert byte array to XML
    $xmlOutput = ConvertToXML123 $loginrequest_arr

    # only for debugging
    # Write-Host $xmlOutput
    Write-Host "----------------------------------------------------------------------"

    # Create an XmlDocument object and load XML data
    $xml = New-Object System.Xml.XmlDocument
    $xml.LoadXml($xmlOutput)



    $TDSVersion = ($xml.GetElementsByTagName("TDSVersion")).InnerText.Replace(" ", "")
    # Add elements to the hashtable
    $dictionary["TDSVersion"] = "0x"+$TDSVersion

    $Length = $xml.GetElementsByTagName("Length")
    $PacketSize = $xml.GetElementsByTagName("PacketSize")
    $ClientPID = $xml.GetElementsByTagName("ClientPID")
    $ConnectionID = $xml.GetElementsByTagName("ConnectionID")

    # # Get elements by tag name
    $ibHostName = $xml.GetElementsByTagName("ibHostName")
    $cchHostName = $xml.GetElementsByTagName("cchHostName")
    $ibUserName = $xml.GetElementsByTagName("ibUserName")
    $cchUserName = $xml.GetElementsByTagName("cchUserName")
    $ibPassword = $xml.GetElementsByTagName("ibPassword")
    $cchPassword = $xml.GetElementsByTagName("cchPassword")
    $ibAppName = $xml.GetElementsByTagName("ibAppName")
    $cchAppName = $xml.GetElementsByTagName("cchAppName")
    $ibServerName = $xml.GetElementsByTagName("ibServerName")
    $cchServerName = $xml.GetElementsByTagName("cchServerName")
    $ibUnused = $xml.GetElementsByTagName("ibUnused")
    $cbUnused = $xml.GetElementsByTagName("cbUnused")
    $ibCltIntName = $xml.GetElementsByTagName("ibCltIntName")
    $cchCltIntName = $xml.GetElementsByTagName("cchCltIntName")
    $ibLanguage = $xml.GetElementsByTagName("ibLanguage")
    $cchLanguage = $xml.GetElementsByTagName("cchLanguage")
    $ibDatabase = $xml.GetElementsByTagName("ibDatabase")
    $cchDatabase = $xml.GetElementsByTagName("cchDatabase")
    $ClientID = $xml.GetElementsByTagName("ClientID")
    $ibSSPI = $xml.GetElementsByTagName("ibSSPI")
    $cbSSPI = $xml.GetElementsByTagName("cbSSPI")
    $ibAtchDBFile = $xml.GetElementsByTagName("ibAtchDBFile")
    $cchAtchDBFile = $xml.GetElementsByTagName("cchAtchDBFile")
    $ibChangePassword = $xml.GetElementsByTagName("ibChangePassword")
    $cchChangePassword = $xml.GetElementsByTagName("cchChangePassword")
    $cbSSPILong = $xml.GetElementsByTagName("cbSSPILong")
    $Data = $xml.GetElementsByTagName("Data")


    # # calculate the decimal value for all variables
    $Length_dec = [Convert]::ToInt32($($Length[1].InnerText).Replace(" ", ""), 16)
    $PacketSize_dec = [Convert]::ToInt32($($PacketSize.InnerText).Replace(" ", ""), 16)
    $ClientPID_dec = [Convert]::ToInt32($($ClientPID.InnerText).Replace(" ", ""), 16)
    $ConnectionID_dec = [Convert]::ToInt32($($ConnectionID.InnerText).Replace(" ", ""), 16)
    $dictionary["Length"] = $Length_dec
    $dictionary["PacketSize"] = $PacketSize_dec
    $dictionary["ClientPID"] = $ClientPID_dec
    $dictionary["ConnectionID"] = $ConnectionID_dec

    $ibHostName_dec = [Convert]::ToInt32($($ibHostName.InnerText).Replace(" ", ""), 16)
    $cchHostName_dec = [Convert]::ToInt32($($cchHostName.InnerText).Replace(" ", ""), 16)
    $ibUserName_dec = [Convert]::ToInt32($($ibUserName.InnerText).Replace(" ", ""), 16)
    $cchUserName_dec = [Convert]::ToInt32($($cchUserName.InnerText).Replace(" ", ""), 16)
    $ibPassword_dec = [Convert]::ToInt32($($ibPassword.InnerText).Replace(" ", ""), 16)
    $cchPassword_dec = [Convert]::ToInt32($($cchPassword.InnerText).Replace(" ", ""), 16)
    $ibAppName_dec = [Convert]::ToInt32($($ibAppName.InnerText).Replace(" ", ""), 16)
    $cchAppName_dec = [Convert]::ToInt32($($cchAppName.InnerText).Replace(" ", ""), 16)
    $ibServerName_dec = [Convert]::ToInt32($($ibServerName.InnerText).Replace(" ", ""), 16)
    $cchServerName_dec = [Convert]::ToInt32($($cchServerName.InnerText).Replace(" ", ""), 16)
    $ibUnused_dec = [Convert]::ToInt32($($ibUnused.InnerText).Replace(" ", ""), 16)
    $cbUnused_dec = [Convert]::ToInt32($($cbUnused.InnerText).Replace(" ", ""), 16)
    $ibCltIntName_dec = [Convert]::ToInt32($($ibCltIntName.InnerText).Replace(" ", ""), 16)
    $cchCltIntName_dec = [Convert]::ToInt32($($cchCltIntName.InnerText).Replace(" ", ""), 16)
    $ibLanguage_dec = [Convert]::ToInt32($($ibLanguage.InnerText).Replace(" ", ""), 16)
    $cchLanguage_dec = [Convert]::ToInt32($($cchLanguage.InnerText).Replace(" ", ""), 16)
    $ibDatabase_dec = [Convert]::ToInt32($($ibDatabase.InnerText).Replace(" ", ""), 16)
    $cchDatabase_dec = [Convert]::ToInt32($($cchDatabase.InnerText).Replace(" ", ""), 16)
    #$ClientID_dec = [Convert]::ToInt32($($ClientID.InnerText).Replace(" ", ""), 16)   # does not comply with hex value
    $ibSSPI_dec = [Convert]::ToInt32($($ibSSPI.InnerText).Replace(" ", ""), 16)
    $cbSSPI_dec = [Convert]::ToInt32($($cbSSPI.InnerText).Replace(" ", ""), 16)
    $ibAtchDBFile_dec = [Convert]::ToInt32($($ibAtchDBFile.InnerText).Replace(" ", ""), 16)
    $cchAtchDBFile_dec = [Convert]::ToInt32($($cchAtchDBFile.InnerText).Replace(" ", ""), 16)
    $ibChangePassword_dec = [Convert]::ToInt32($($ibChangePassword.InnerText).Replace(" ", ""), 16)
    $cchChangePassword_dec = [Convert]::ToInt32($($cchChangePassword.InnerText).Replace(" ", ""), 16)
    $ibSSPI_dec = [Convert]::ToInt32($($ibSSPI.InnerText).Replace(" ", ""), 16)
    $cbSSPI_dec = [Convert]::ToInt32($($cbSSPI.InnerText).Replace(" ", ""), 16)
    $cbSSPILong_dec = [Convert]::ToInt32($($cbSSPILong.InnerText).Replace(" ", ""), 16)



    # # Output for all variables - in decimal - for debugging use
    # Write-Host "ibHostName_dec: $ibHostName_dec"
    # Write-Host "cchHostName_dec: $cchHostName_dec"
    # Write-Host "ibUserName_dec: $ibUserName_dec"
    # Write-Host "cchUserName_dec: $cchUserName_dec"
    # Write-Host "ibPassword_dec: $ibPassword_dec"
    # Write-Host "cchPassword_dec: $cchPassword_dec"
    # Write-Host "ibAppName_dec: $ibAppName_dec"
    # Write-Host "cchAppName_dec: $cchAppName_dec"
    # Write-Host "ibServerName_dec: $ibServerName_dec"
    # Write-Host "cchServerName_dec: $cchServerName_dec"
    # Write-Host "ibUnused_dec: $ibUnused_dec"
    # Write-Host "cbUnused_dec: $cbUnused_dec"
    # Write-Host "ibCltIntName_dec: $ibCltIntName_dec"
    # Write-Host "cchCltIntName_dec: $cchCltIntName_dec"
    # Write-Host "ibLanguage_dec: $ibLanguage_dec"
    # Write-Host "cchLanguage_dec: $cchLanguage_dec"
    # Write-Host "ibDatabase_dec: $ibDatabase_dec"
    # Write-Host "cchDatabase_dec: $cchDatabase_dec"
    # Write-Host "ClientID_dec: $ClientID_dec"
    # Write-Host "ibSSPI_dec: $ibSSPI_dec"
    # Write-Host "cbSSPI_dec: $cbSSPI_dec"
    # Write-Host "ibAtchDBFile_dec: $ibAtchDBFile_dec"
    # Write-Host "cchAtchDBFile_dec: $cchAtchDBFile_dec"
    # Write-Host "ibChangePassword_dec: $ibChangePassword_dec"
    # Write-Host "cchChangePassword_dec: $cchChangePassword_dec"
    # Write-Host "cbSSPILong_dec: $cbSSPILong_dec"
    # Write-Host "----------------------------------------------------------------------"



    $HostName = GetFieldValue $loginrequest_arr $ibHostName_dec $cchHostName_dec
    $UserName = GetFieldValue $loginrequest_arr $ibUserName_dec $cchUserName_dec
    $Password = GetFieldValue $loginrequest_arr $ibPassword_dec $cchPassword_dec
    $AppName = GetFieldValue $loginrequest_arr $ibAppName_dec $cchAppName_dec
    $ServerName = GetFieldValue $loginrequest_arr $ibServerName_dec $cchServerName_dec
    $Unused = GetFieldValue $loginrequest_arr $ibUnused_dec $cbUnused_dec
    $CltIntName = GetFieldValue $loginrequest_arr $ibCltIntName_dec $cchCltIntName_dec
    $Language = GetFieldValue $loginrequest_arr $ibLanguage_dec $cchLanguage_dec
    $Database = GetFieldValue $loginrequest_arr $ibDatabase_dec $cchDatabase_dec
    $SSPI = GetFieldValue $loginrequest_arr $ibSSPI_dec $cchSSPI_dec
    $AtchDBFile = GetFieldValue $loginrequest_arr $ibAtchDBFile_dec $cchAtchDBFile_dec
    $ChangePassword  = GetFieldValue $loginrequest_arr $ibChangePassword_dec $cchChangePassword_dec



    # Output for all variables - for debugging
    # Write-Host "HostName: $HostName"
    # Write-Host "UserName: $UserName"
    # Write-Host "Password: $Password"
    # Write-Host "AppName: $AppName"
    # Write-Host "ServerName: $ServerName"
    # Write-Host "Unused: $Unused"
    # Write-Host "CltIntName: $CltIntName"
    # Write-Host "Language: $Language"
    # Write-Host "Database: $Database"
    # Write-Host "SSPI: $SSPI"
    # Write-Host "AtchDBFile: $AtchDBFile"
    # Write-Host "ChangePassword: $ChangePassword"
    # # Write-Host "----------------------------------------------------------------------"



    # Add elements to the hashtable
    $dictionary["HostName"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $HostName)
    $dictionary["UserName"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $UserName)
    $dictionary["Password"] = PWDDecoder $Password
    $dictionary["AppName"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $AppName)
    $dictionary["ServerName"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $ServerName)
    $dictionary["Unused"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $Unused)
    $dictionary["CltIntName"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $CltIntName)
    $dictionary["Language"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $Language)
    $dictionary["Database"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $Database)
    $dictionary["SSPI"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $SSPI)
    $dictionary["AtchDBFile"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $AtchDBFile)
    $dictionary["ChangePassword"] = ConvertHexArrayToPlaintext (ConvertLittleToBigEndian $ChangePassword)
    # Print the dictionary - debugging
    #$dictionary

    # Print the dictionary
    foreach ($key in $dictionary.Keys) {
        Write-Host "${key}: $($dictionary[$key])"
    }

    Write-Host "----------------------------------------------------------------------"


    # end of the script
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
#Write-Host "--------------------------------------------------------------------------------"


switch ($str_arr[0]) {
    "10" { 
        # Login Request
        LoginRequestHandler $str_arr
    }

    "04" {
        # Table Response(Login response, SQL Batch response,..
        TableResponseHandler $str_arr

    }
}




# end of the script















