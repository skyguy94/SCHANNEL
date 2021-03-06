function _GetSSLProtocol {
    param([string]$SSLProtocol)

    return @{
        ServerEnabled = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Server" -Name Enabled -ErrorAction SilentlyContinue
        ServerDisabledByDefault = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Server" -Name DisabledByDefault -ErrorAction SilentlyContinue
        ClientEnabled = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Client" -Name Enabled -ErrorAction SilentlyContinue
        ClientDisabledByDefault = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Client" -Name DisabledByDefault -ErrorAction SilentlyContinue
    }
}

function _SetSSLProtocol {
    param(
        [string]$SSLProtocol,
        $Enabled
    )
     
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol" -Force
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Server" -Force
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Client" -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Server" -Name Enabled -Value $Enabled -PropertyType 'DWord' -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Server" -Name DisabledByDefault -Value 0 -PropertyType 'DWord' -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Client" -Name Enabled -Value $Enabled -PropertyType 'DWord' -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$SSLProtocol\Client" -Name DisabledByDefault -Value 0 -PropertyType 'DWord' -Force
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SSLProtocol
    )

    return @{
        SSLProtocol = $SSLProtocol
        Enabled = (_GetSSLProtocol $SSLProtocol) -eq '0xffffffff'
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SSLProtocol,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
    $enable = if ($Ensure -eq 'Present') { '0xffffffff' } else { '0x0' }
    _SetSSLProtocol $SSLProtocol $enable
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SSLProtocol,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
    

    $enable = $Ensure -eq 'Present'
    $state =  (Get-TargetResource $SSLProtocol).Enabled
    return $state -eq $enable
}

Export-ModuleMember -Function *-TargetResource