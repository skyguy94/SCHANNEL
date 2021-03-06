function _GetHash{
    param([string]$Hash)
    $val = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\$Hash" -Name Enabled -ErrorAction SilentlyContinue).Enabled
    '0x{0:x}' -f $val
}

function _SetHash {
    param(
        [string]$Hash,
        $Enabled
    )
     
	New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\$Hash" -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\$Hash" -Name Enabled -Value $Enabled -PropertyType 'DWord' -Force
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Hash
    )

	return @{
        Hash = $Hash
        Enabled = (_GetHash $Hash) -eq '0xffffffff'
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Hash,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
	$enable = if ($Ensure -eq 'Present') { '0xffffffff' } else { '0x0' }
    _SetHash $Hash $enable
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Hash,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )
	

	$enable = $Ensure -eq 'Present'
    $state =  (Get-TargetResource $Hash).Enabled
    return $state -eq $enable
}

Export-ModuleMember -Function *-TargetResource

