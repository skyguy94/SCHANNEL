function _GetCipher {
    param([string]$Cipher)
    $val = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$Cipher" -Name Enabled -ErrorAction SilentlyContinue).Enabled
    '0x{0:x}' -f $val
}

function _SetCipher {
    param(
        [string]$Cipher,
        $Enabled
    )
     
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$Cipher" -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$Cipher" -Name Enabled -Value $Enabled -PropertyType 'DWord' -Force
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Cipher
    )

    return @{
        Cipher = $Cipher
        Enabled = (_GetCipher $Cipher) -eq '0xffffffff'
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Cipher,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
    $enable = if ($Ensure -eq 'Present') { '0xffffffff' } else { '0x0' }
    _SetCipher $Cipher $enable
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Cipher,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
    

    $enable = $Ensure -eq 'Present'
    $state =  (Get-TargetResource $Cipher).Enabled
    return $state -eq $enable
}


Export-ModuleMember -Function *-TargetResource

