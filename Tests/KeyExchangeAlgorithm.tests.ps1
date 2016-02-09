Import-Module -Name "$PSScriptRoot\..\DSCResources\KeyExchangeAlgorithm"
InModuleScope 'KeyExchangeAlgorithm' {
    Describe 'KeyExchangeAlgorithm is a DSC Resource' {

        Context "Meets DSC syntax requirements" {
            It 'Should be syntactically correct' {
                $res = Test-xDscSchema -Path (Join-Path (Get-Location) "$PSScriptRoot\..\DSCResources\KeyExchangeAlgorithm\KeyExchangeAlgorithm.schema.mof")
                $res | Should Be $true
            }

            It 'Should be a well formed resource' {
                $res = Test-xDscResource -Name (Join-Path (Get-Location) "$PSScriptRoot\..\DSCResources\KeyExchangeAlgorithm")

                $res | Should Be $true
            }
        }

        Context "Given a set of configured algorithms" {
            Mock _GetAlgorithm -MockWith {
                if ($Algorithm -contains 'PKCS') {
                    0xffffffff
                } else {
                    0x0
                }
            }

            It 'Should have Get-TargetResource return $false for a disabled algorithm.' {
                (Get-TargetResource -Algorithm 'NULL').Enabled |  Should Be $false
            }

            It 'Should have Get-TargetResource return $true for an enabled algorithm.' {
                (Get-TargetResource -Algorithm 'PKCS').Enabled |  Should Be $true
            }

            It 'Should have Test-TargetResource return $false when a Present algorithm is unexpectedly Absent.' {
                Test-TargetResource -Algorithm 'ShouldExist' -Ensure Present | Should Be $false
            }

            It 'Should have Test-TargetResource return $false when an Absent algorithm is unexpectedly Present.' {
                Test-TargetResource -Algorithm 'PKCS' -Ensure Absent | Should Be $false
            }

            It 'Should have Test-TargetResource return $true when a Present algorithm is Present.' {
                Test-TargetResource -Algorithm 'PKCS' -Ensure Present | Should Be $true
            }

            It 'Should have Test-TargetResource return $false when an Absent algorithm is Absent.' {
                Test-TargetResource -Algorithm 'NULL' -Ensure Absent | Should Be $true
            }

        }

        Context "Given a set of unconfigured algorithms" {
            Mock _SetAlgorithm -Verifiable

            It 'Should have Set-TargetResource enable a resource' {
                Set-TargetResource -Algorithm 'NULL' -Ensure Present
                Assert-MockCalled _SetAlgorithm -ParameterFilter { $Algorithm -eq 'NULL' -and $Enabled -eq '0xffffffff' }
            }

            It 'Should have Set-TargetResource disable a resource' {
                Set-TargetResource -Algorithm 'NULL' -Ensure Absent
                Assert-MockCalled _SetAlgorithm -ParameterFilter { $Algorithm -eq 'NULL' -and $Enabled -eq '0x0' }
            }
        }

        Context "Given a live environment" {
            It 'Should not throw if a algorithm does not exist' {
                { Get-TargetResource -Algorithm 'Harbinger' } | Should Not Throw
                { Test-TargetResource -Algorithm 'Harbinger' } | Should Not Throw
            }

            It 'Should enable a resource' {
                try {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\TestAlgorithm" -Force -Confirm:$false -ErrorAction SilentlyContinue
                    Test-TargetResource -Algorithm 'TestAlgorithm' -Ensure Present | Should Be $false
                    (Get-TargetResource -Algorithm 'TestAlgorithm').Enabled | Should Be $false
                    
                    Set-TargetResource -Algorithm 'TestAlgorithm' -Ensure Present

                    Test-TargetResource -Algorithm 'TestAlgorithm' -Ensure Present | Should Be $true
                    (Get-TargetResource -Algorithm 'TestAlgorithm').Enabled | Should Be $true

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\TestAlgorithm" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            It 'Should disable a resource' {
                try {
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\TestAlgorithm" -Force
                    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\TestAlgorithm" -Name Enabled -Value 0xffffffff -PropertyType 'DWord' -Force

                    Test-TargetResource -Algorithm 'TestAlgorithm' -Ensure Present | Should Be $true
                    (Get-TargetResource -Algorithm 'TestAlgorithm').Enabled | Should Be $true
                    
                    Set-TargetResource -Algorithm 'TestAlgorithm' -Ensure Absent

                    Test-TargetResource -Algorithm 'TestAlgorithm' -Ensure Absent | Should Be $true
                    (Get-TargetResource -Algorithm 'TestAlgorithm').Enabled | Should Be $false

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\TestAlgorithm" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
