function _GetAlgorithm{
    param([string]$Algorithm)
    $val = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\$Algorithm" -Name Enabled -ErrorAction SilentlyContinue).Enabled
    '0x{0:x}' -f $val
}

function _SetAlgorithm {
    param(
        [string]$Algorithm,
        $Enabled
    )
     
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\$Algorithm" -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\$Algorithm" -Name Enabled -Value $Enabled -PropertyType 'DWord' -Force
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Algorithm
    )

	return @{
        Algorithm = $Algorithm
        Enabled = (_GetAlgorithm $Algorithm) -eq '0xffffffff'
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Algorithm,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
	$enable = if ($Ensure -eq 'Present') { '0xffffffff' } else { '0x0' }
    _SetAlgorithm $Algorithm $enable
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Algorithm,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
	

	$enable = $Ensure -eq 'Present'
    $state =  (Get-TargetResource $Algorithm).Enabled
    return $state -eq $enable
}

Export-ModuleMember -Function *-TargetResource