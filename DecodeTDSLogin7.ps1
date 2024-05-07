## Author : Matt Changchien
## Email: matt.changchien@microsoft.com
##

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








## Main starts here

# variables declaration
# Create a hashtable
$dictionary = @{}

# Prompt the user for input
$userInput = Read-Host -Prompt 'Please enter a string'

# Print the user's input
Write-Host "You entered: $userInput"

# Convert hexadecimal string to byte array
$str_arr = [string[]]($userInput -split '([0-9A-F]{2})' | Where-Object { $_ -ne '' })

# only for debugging
#Write-Host $str_arr


# Convert byte array to XML
$xmlOutput = ConvertToXML123 $str_arr

# only for debugging
Write-Host $xmlOutput
Write-Host "----------------------------------------------------------------------"

# Create an XmlDocument object and load XML data
$xml = New-Object System.Xml.XmlDocument
$xml.LoadXml($xmlOutput)



$TDSVersion = ($xml.GetElementsByTagName("TDSVersion")).InnerText.Replace(" ", "")
# Add elements to the hashtable
$dictionary["TDSVersion"] = $TDSVersion

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



Write-Host ($Length[1]).InnerText
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


# Output for all variables - in original value - for debugging use
# Write-Host "PacketSize: $($PacketSize.InnerText)"
# Write-Host "ClientPID: $($ClientPID.InnerText)"
# Write-Host "ConnectionID: $($ConnectionID.InnerText)"
# Write-Host "ibHostName: $($ibHostName.InnerText)"
# Write-Host "cchHostName: $($cchHostName.InnerText)"
# Write-Host "ibUserName: $($ibUserName.InnerText)"
# Write-Host "cchUserName: $($cchUserName.InnerText)"
# Write-Host "ibPassword: $($ibPassword.InnerText)"
# Write-Host "cchPassword: $($cchPassword.InnerText)"
# Write-Host "ibAppName: $($ibAppName.InnerText)"
# Write-Host "cchAppName: $($cchAppName.InnerText)"
# Write-Host "ibServerName: $($ibServerName.InnerText)"
# Write-Host "cchServerName: $($cchServerName.InnerText)"
# Write-Host "ibUnused: $($ibUnused.InnerText)"
# Write-Host "cbUnused: $($cbUnused.InnerText)"
# Write-Host "ibCltIntName: $($ibCltIntName.InnerText)"
# Write-Host "cchCltIntName: $($cchCltIntName.InnerText)"
# Write-Host "ibLanguage: $($ibLanguage.InnerText)"
# Write-Host "cchLanguage: $($cchLanguage.InnerText)"
# Write-Host "ibDatabase: $($ibDatabase.InnerText)"
# Write-Host "cchDatabase: $($cchDatabase.InnerText)"
# Write-Host "ClientID: $($ClientID.InnerText)"
# Write-Host "ibSSPI: $($ibSSPI.InnerText)"
# Write-Host "cbSSPI: $($cbSSPI.InnerText)"
# Write-Host "ibAtchDBFile: $($ibAtchDBFile.InnerText)"
# Write-Host "cchAtchDBFile: $($cchAtchDBFile.InnerText)"
# Write-Host "ibChangePassword: $($ibChangePassword.InnerText)"
# Write-Host "cchChangePassword: $($cchChangePassword.InnerText)"
# Write-Host "cbSSPILong: $($cbSSPILong.InnerText)"
# Write-Host "Data: $($Data.InnerText)"



# # Output for all variables - in decimal - for debugging use
Write-Host "ibHostName_dec: $ibHostName_dec"
Write-Host "cchHostName_dec: $cchHostName_dec"
Write-Host "ibUserName_dec: $ibUserName_dec"
Write-Host "cchUserName_dec: $cchUserName_dec"
Write-Host "ibPassword_dec: $ibPassword_dec"
Write-Host "cchPassword_dec: $cchPassword_dec"
Write-Host "ibAppName_dec: $ibAppName_dec"
Write-Host "cchAppName_dec: $cchAppName_dec"
Write-Host "ibServerName_dec: $ibServerName_dec"
Write-Host "cchServerName_dec: $cchServerName_dec"
Write-Host "ibUnused_dec: $ibUnused_dec"
Write-Host "cbUnused_dec: $cbUnused_dec"
Write-Host "ibCltIntName_dec: $ibCltIntName_dec"
Write-Host "cchCltIntName_dec: $cchCltIntName_dec"
Write-Host "ibLanguage_dec: $ibLanguage_dec"
Write-Host "cchLanguage_dec: $cchLanguage_dec"
Write-Host "ibDatabase_dec: $ibDatabase_dec"
Write-Host "cchDatabase_dec: $cchDatabase_dec"
Write-Host "ClientID_dec: $ClientID_dec"
Write-Host "ibSSPI_dec: $ibSSPI_dec"
Write-Host "cbSSPI_dec: $cbSSPI_dec"
Write-Host "ibAtchDBFile_dec: $ibAtchDBFile_dec"
Write-Host "cchAtchDBFile_dec: $cchAtchDBFile_dec"
Write-Host "ibChangePassword_dec: $ibChangePassword_dec"
Write-Host "cchChangePassword_dec: $cchChangePassword_dec"
Write-Host "cbSSPILong_dec: $cbSSPILong_dec"
Write-Host "----------------------------------------------------------------------"









#$Data_basedonOffSet = $str_arr[($ibHostName_dec+8)..$str_arr.Length]
#Write-Host "Data_basedonOffSet: $Data_basedonOffSet"
#Write-Host "Data: $($Data.InnerText)"




$HostName = GetFieldValue $str_arr $ibHostName_dec $cchHostName_dec
$UserName = GetFieldValue $str_arr $ibUserName_dec $cchUserName_dec
$Password = GetFieldValue $str_arr $ibPassword_dec $cchPassword_dec
$AppName = GetFieldValue $str_arr $ibAppName_dec $cchAppName_dec
$ServerName = GetFieldValue $str_arr $ibServerName_dec $cchServerName_dec
$Unused = GetFieldValue $str_arr $ibUnused_dec $cbUnused_dec
$CltIntName = GetFieldValue $str_arr $ibCltIntName_dec $cchCltIntName_dec
$Language = GetFieldValue $str_arr $ibLanguage_dec $cchLanguage_dec
$Database = GetFieldValue $str_arr $ibDatabase_dec $cchDatabase_dec
$SSPI = GetFieldValue $str_arr $ibSSPI_dec $cchSSPI_dec
$AtchDBFile = GetFieldValue $str_arr $ibAtchDBFile_dec $cchAtchDBFile_dec
$ChangePassword  = GetFieldValue $str_arr $ibChangePassword_dec $cchChangePassword_dec




# $HostName = $str_arr[($ibHostName_dec+8)..($ibHostName_dec+8+$cchHostName_dec*2-1)]
# $UserName = $str_arr[($ibUserName_dec+8)..($ibUserName_dec+8+$cchUserName_dec*2-1)]
# $Password = $str_arr[($ibPassword_dec+8)..($ibPassword_dec+8+$cchPassword_dec*2-1)]
# $AppName = $str_arr[($ibAppName_dec+8)..($ibAppName_dec+8+$cchAppName_dec*2-1)]
# $ServerName = $str_arr[($ibServerName_dec+8)..($ibServerName_dec+8+$cchServerName_dec*2-1)]
# $Unused = $str_arr[($ibUnused_dec+8)..($ibUnused_dec+8+$cbUnused_dec*2-1)]
# $CltIntName = $str_arr[($ibCltIntName_dec+8)..($ibCltIntName_dec+8+$cchCltIntName_dec*2-1)]
# $Language = $str_arr[($ibLanguage_dec+8)..($ibLanguage_dec+8+$cchLanguage_dec*2-1)]
# $Database = $str_arr[($ibDatabase_dec+8)..($ibDatabase_dec+8+$cchDatabase_dec*2-1)]
# $SSPI = $str_arr[($ibSSPI_dec+8)..($ibSSPI_dec+8+$cchSSPI_dec*2-1)]
# $AtchDBFile = $str_arr[($ibAtchDBFile_dec+8)..($ibAtchDBFile_dec+8+$cchAtchDBFile_dec*2-1)]
# $ChangePassword = $str_arr[($ibChangePassword_dec+8)..($ibChangePassword_dec+8+$cchChangePassword_dec*2-1)]





# Output for all variables - for debugging
Write-Host "HostName: $HostName"
Write-Host "UserName: $UserName"
Write-Host "Password: $Password"
Write-Host "AppName: $AppName"
Write-Host "ServerName: $ServerName"
Write-Host "Unused: $Unused"
Write-Host "CltIntName: $CltIntName"
Write-Host "Language: $Language"
Write-Host "Database: $Database"
Write-Host "SSPI: $SSPI"
Write-Host "AtchDBFile: $AtchDBFile"
Write-Host "ChangePassword: $ChangePassword"
Write-Host "----------------------------------------------------------------------"



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















