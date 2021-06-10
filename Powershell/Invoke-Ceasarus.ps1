function Invoke-Ceasarus
{
<#
.SYNOPSIS

Encode shellcodes using ceasar cipher.
Author: Mamadou Lamine NIANG (@mlniang)
License: BSD 3-Clause  
Required Dependencies: None  
Optional Dependencies: None

.DESCRIPTION

Transforms every byte of a shellcode by applying the ceasar cipher to it.

.PARAMETER Bytes

Specifies the bytes of the shellcode to encode.

.PARAMETER Base64

Specifies the base64 shellcode to encode.

.PARAMETER Path

Specifies the path to a file containing the shellcode to encode.

.PARAMETER Shift

Specifies an integer between 5 and 100 representing the shift to apply to the bytes. Defaults to a random integer between 5 and 100.

.PARAMETER Format

Specifies the output format (raw, b64 or binfile for binary file). Defaults to the input format.

.PARAMETER OutPath

Specifies a path to a file to save output. Default is printed on console.

.EXAMPLE

C:\PS> Invoke-Ceasarus -Bytes $bytes -Format b64

C:\PS> Invoke-Ceasarus -Base64 $shellcode64 -Shift 6 -Format b64 -OutPath C:\Temp\shifted.txt

C:\PS> Invoke-Ceasarus -Path .\meterpreter.bin -Format binfile

.LINK
https://github.com/mlniang/evasor
#>

    [CmdletBinding(DefaultParameterSetName = 'noOptions')]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True, ParameterSetName = 'Bytes')]
        [ValidateNotNullOrEmpty()]
        $Bytes,

        [Parameter(Position = 0, ValueFromPipeline = $True, ParameterSetName = 'Base64')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Base64,

        [Parameter(Position = 0, ParameterSetName = 'Path')]
        [ValidateScript({Test-Path $_ })]
        [String]
        $Path,

        [UInt32]
        [ValidateRange(5,100)]
        $Shift,

        [String]
        [ValidateSet('raw', 'b64', 'binfile')]
        $Format,

        [String]
        $OutPath = 'ceasarus_output'
    )

    # Check if either -Bytes or -Base64 or -Path is specified
    if($PSCmdlet.ParameterSetName -eq 'noOptions'){
        throw 'Please pass either "-Bytes", "-Base64" or "-Path"'
        return
    }

    # Set variables from input
    $InputFormat = 'raw'
    if($PSBoundParameters['Base64'])
    {
        $Bytes = [System.Convert]::FromBase64String($Base64)
        $InputFormat = 'b64'
    }
    elseif($PSBoundParameters['Path'])
    {
        $Bytes = [System.IO.File]::ReadAllBytes($Path)
    }
    # If output format is not given use the same format as input
    if(!$PSBoundParameters['Format'])
    {
        $Format = $InputFormat
    }
    # If shift is not given, use a random value between 5 and 100
    if(!$PSBoundParameters['Shift'])
    {
        $Shift = Get-Random -Minimum 5 -Maximum 100
    }
    
    [Byte[]] $encoded = [Byte[]]::new($Bytes.Length)
    for($i = 0; $i -lt $Bytes.Length; $i++)
    {
        $Encoded[$i] = [Byte](([uint32]$Bytes[$i] + $Shift) -band 0xFF)
    }

    # If output format is binfile, save it
    $FallbackOutput = $False
    if($Format -eq 'binfile')
    {
        try
        {
            [System.IO.File]::WriteAllBytes($OutPath, $Encoded)
            Write-Host "Binary File written to $OutPath with Shift of $Shift"
            return
        }
        catch
        {
            Write-Error "Error writing binary file to $OutPath`nFalling back to raw output"
            $FallbackOutput = $True
        }
    }

    # Build raw or base64 the output
    $OutPut = "Shift: $Shift`nOutput: "
    if($Format -eq 'b64')
    {
        $OutPut += [System.Convert]::ToBase64String($Encoded)
    }
    else
    {
        $OutPut += '0x' + (($Encoded | ForEach-Object ToString X2) -join ',0x')
    }

    if($PSBoundParameters['OutPath'] -and !$FallbackOutput)
    {
        try
        {
            Out-File -InputObject $OutPut -FilePath $OutPath
            Write-Host "Output written to $OutPath"
        }
        catch
        {
            Write-Error "Error when writing output to $OutPath"
            Write-Error "Printing it to the console as fallback"
            Write-Error "$OutPut"
        }
    }
    else
    {
        Write-Host "$OutPut"
    }
    
}