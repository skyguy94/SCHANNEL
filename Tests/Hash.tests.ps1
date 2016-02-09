Import-Module -Name "$PSScriptRoot\..\DSCResources\Hash"
InModuleScope 'Hash' {
    Describe 'Hash is a DSC Resource' {

        Context "Meets DSC syntax requirements" {
            It 'Should be syntactically correct' {
                $res = Test-xDscSchema -Path (Join-Path (Get-Location) "..\DSCResources\Hash\Hash.schema.mof")
                $res | Should Be $true
            }

            It 'Should be a well formed resource' {
                $res = Test-xDscResource -Name (Join-Path (Get-Location) "..\DSCResources\Hash")

                $res | Should Be $true
            }
        }

        Context "Given a set of configured hashes" {
            Mock _GetHash -MockWith {
                if ($Hash -contains 'SHA256') {
                    0xffffffff
                } else {
                    0x0
                }
            }

            It 'Should have Get-TargetResource return $false for a disabled hash.' {
                (Get-TargetResource -Hash 'NULL').Enabled |  Should Be $false
            }

            It 'Should have Get-TargetResource return $true for an enabled hash.' {
                (Get-TargetResource -Hash 'SHA256').Enabled |  Should Be $true
            }

            It 'Should have Test-TargetResource return $false when a Present hash is unexpectedly Absent.' {
                Test-TargetResource -Hash 'ShouldExist' -Ensure Present | Should Be $false
            }

            It 'Should have Test-TargetResource return $false when an Absent hash is unexpectedly Present.' {
                Test-TargetResource -Hash 'SHA256' -Ensure Absent | Should Be $false
            }

            It 'Should have Test-TargetResource return $true when a Present hash is Present.' {
                Test-TargetResource -Hash 'SHA256' -Ensure Present | Should Be $true
            }

            It 'Should have Test-TargetResource return $false when an Absent hash is Absent.' {
                Test-TargetResource -Hash 'NULL' -Ensure Absent | Should Be $true
            }

        }

        Context "Given a set of unconfigured hashes" {
            Mock _SetHash -Verifiable

            It 'Should have Set-TargetResource enable a resource' {
                Set-TargetResource -Hash 'NULL' -Ensure Present
                Assert-MockCalled _SetHash -ParameterFilter { $Hash -eq 'NULL' -and $Enabled -eq '0xffffffff' }
            }

            It 'Should have Set-TargetResource disable a resource' {
                Set-TargetResource -Hash 'NULL' -Ensure Absent
                Assert-MockCalled _SetHash -ParameterFilter { $Hash -eq 'NULL' -and $Enabled -eq '0x0' }
            }
        }

        Context "Given a live environment" {
            It 'Should not throw if a hash does not exist' {
                { Get-TargetResource -Hash 'Harbinger' } | Should Not Throw
                { Test-TargetResource -Hash 'Harbinger' } | Should Not Throw
            }

            It 'Should enable a resource' {
                try {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\TestHash" -Force -Confirm:$false -ErrorAction SilentlyContinue
                    Test-TargetResource -Hash 'TestHash' -Ensure Present | Should Be $false
                    (Get-TargetResource -Hash 'TestHash').Enabled | Should Be $false
                    
                    Set-TargetResource -Hash 'TestHash' -Ensure Present

                    Test-TargetResource -Hash 'TestHash' -Ensure Present | Should Be $true
                    (Get-TargetResource -Hash 'TestHash').Enabled | Should Be $true

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\TestHash" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            It 'Should disable a resource' {
                try {
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\TestHash" -Force
                    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\TestHash" -Name Enabled -Value 0xffffffff -PropertyType 'DWord' -Force

                    Test-TargetResource -Hash 'TestHash' -Ensure Present | Should Be $true
                    (Get-TargetResource -Hash 'TestHash').Enabled | Should Be $true
                    
                    Set-TargetResource -Hash 'TestHash' -Ensure Absent

                    Test-TargetResource -Hash 'TestHash' -Ensure Absent | Should Be $true
                    (Get-TargetResource -Hash 'TestHash').Enabled | Should Be $false

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hash\TestHash" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
