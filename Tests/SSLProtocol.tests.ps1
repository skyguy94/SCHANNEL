Import-Module -Name '..\DSCResources\SSLProtocol'
InModuleScope 'SSLProtocol' {
    Describe 'SSLProtocol is a DSC Resource' {

        Context "Meets DSC syntax requirements" {
	        It 'Should be syntactically correct' {
		        $res = Test-xDscSchema -Path (Join-Path (Get-Location) "..\DSCResources\SSLProtocol\SSLProtocol.schema.mof")
                $res | Should Be $true
	        }

            It 'Should be a well formed resource' {
		        $res = Test-xDscResource -Name (Join-Path (Get-Location) "..\DSCResources\SSLProtocol")

                $res | Should Be $true
            }
        }

        Context "Given a set of configured protocols" {
            Mock _GetSSLProtocol -MockWith {
                if ($SSLProtocol -contains 'AES 256/256') {
                    0xffffffff
                } else {
                    0x0
                }
            }

            It 'Should have Get-TargetResource return $false for a disabled protocol.' {
                (Get-TargetResource -SSLProtocol 'NULL').Enabled |  Should Be $false
            }

            It 'Should have Get-TargetResource return $true for an enabled protocol.' {
                (Get-TargetResource -SSLProtocol 'AES 256/256').Enabled |  Should Be $true
            }

            It 'Should have Test-TargetResource return $false when a Present protocol is unexpectedly Absent.' {
                Test-TargetResource -SSLProtocol 'ShouldExist' -Ensure Present | Should Be $false
            }

            It 'Should have Test-TargetResource return $false when an Absent protocol is unexpectedly Present.' {
                Test-TargetResource -SSLProtocol 'AES 256/256' -Ensure Absent | Should Be $false
            }

            It 'Should have Test-TargetResource return $true when a Present protocol is Present.' {
                Test-TargetResource -SSLProtocol 'AES 256/256' -Ensure Present | Should Be $true
            }

            It 'Should have Test-TargetResource return $false when an Absent protocol is Absent.' {
                Test-TargetResource -SSLProtocol 'NULL' -Ensure Absent | Should Be $true
            }

        }

        Context "Given a set of unconfigured protocols" {
            Mock _SetSSLProtocol -Verifiable

            It 'Should have Set-TargetResource enable a resource' {
                Set-TargetResource -SSLProtocol 'NULL' -Ensure Present
                Assert-MockCalled _SetSSLProtocol -ParameterFilter { $SSLProtocol -eq 'NULL' -and $Enabled -eq '0xffffffff' }
            }

            It 'Should have Set-TargetResource disable a resource' {
                Set-TargetResource -SSLProtocol 'NULL' -Ensure Absent
                Assert-MockCalled _SetSSLProtocol -ParameterFilter { $SSLProtocol -eq 'NULL' -and $Enabled -eq '0x0' }
            }
        }

        Context "Given a live environment" {
            It 'Should not throw if a protocol does not exist' {
                try {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                    { Get-TargetResource -SSLProtocol 'TestProtocol' } | Should Not Throw
                    { Test-TargetResource -SSLProtocol 'TestProtocol' } | Should Not Throw
                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            It 'Should enable a resource' {
                try {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                    Test-TargetResource -SSLProtocol 'TestProtocol' -Ensure Present | Should Be $false
                    (Get-TargetResource -SSLProtocol 'TestProtocol').Enabled | Should Be $false
                    
                    Set-TargetResource -SSLProtocol 'TestProtocol' -Ensure Present

                    Test-TargetResource -SSLProtocol 'TestProtocol' -Ensure Present | Should Be $true
                    (Get-TargetResource -SSLProtocol 'TestProtocol').Enabled | Should Be $true

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            It 'Should disable a resource' {
                try {
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Force -Confirm:$false
                    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Name Enabled -Value 0xffffffff -PropertyType 'DWord' -Force

                    Test-TargetResource -SSLProtocol 'TestProtocol' -Ensure Present | Should Be $true
                    (Get-TargetResource -SSLProtocol 'TestProtocol').Enabled | Should Be $true
                    
                    Set-TargetResource -SSLProtocol 'TestProtocol' -Ensure Absent

                    Test-TargetResource -SSLProtocol 'TestProtocol' -Ensure Absent | Should Be $true
                    (Get-TargetResource -SSLProtocol 'TestProtocol').Enabled | Should Be $false

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TestProtocol" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
