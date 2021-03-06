function _GetCipherOrder {
    $key = Get-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -ErrorAction SilentlyContinue
    $key.GetValue('Functions')
}

function _SetCipherOrder {
    param([string]$Ciphers)
     
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name 'Functions' -Value $Ciphers -PropertyType 'String' -Force
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Ciphers
    )
    return @{
        Ciphers = (_GetCipherOrder)
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Ciphers
    )
    _SetCipherOrder $Ciphers
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Ciphers
    )

    $actual = (_GetCipherOrder)
    return $Ciphers -ieq $actual
}


Export-ModuleMember -Function *-TargetResource