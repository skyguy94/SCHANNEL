Import-Module -Name "$PSScriptRoot\..\DSCResources\Cipher"
InModuleScope 'Cipher' {
    Describe 'Cipher is a DSC Resource' {

        Context "Meets DSC syntax requirements" {
            It 'Should be syntactically correct' {
                $res = Test-xDscSchema -Path (Join-Path (Get-Location) "$PSScriptRoot\..\DSCResources\Cipher\Cipher.schema.mof")
                $res | Should Be $true
            }

            It 'Should be a well formed resource' {
                $res = Test-xDscResource -Name (Join-Path (Get-Location) "$PSScriptRoot\..\DSCResources\Cipher")

                $res | Should Be $true
            }
        }

        Context "Given a set of configured ciphers" {
            Mock _GetCipher -MockWith {
                if ($Cipher -contains 'AES 256/256') {
                    0xffffffff
                } else {
                    0x0
                }
            }

            It 'Should have Get-TargetResource return $false for a disabled cipher.' {
                (Get-TargetResource -Cipher 'NULL').Enabled |  Should Be $false
            }

            It 'Should have Get-TargetResource return $true for an enabled cipher.' {
                (Get-TargetResource -Cipher 'AES 256/256').Enabled |  Should Be $true
            }

            It 'Should have Test-TargetResource return $false when a Present cipher is unexpectedly Absent.' {
                Test-TargetResource -Cipher 'ShouldExist' -Ensure Present | Should Be $false
            }

            It 'Should have Test-TargetResource return $false when an Absent cipher is unexpectedly Present.' {
                Test-TargetResource -Cipher 'AES 256/256' -Ensure Absent | Should Be $false
            }

            It 'Should have Test-TargetResource return $true when a Present cipher is Present.' {
                Test-TargetResource -Cipher 'AES 256/256' -Ensure Present | Should Be $true
            }

            It 'Should have Test-TargetResource return $false when an Absent cipher is Absent.' {
                Test-TargetResource -Cipher 'NULL' -Ensure Absent | Should Be $true
            }

        }

        Context "Given a set of unconfigured ciphers" {
            Mock _SetCipher -Verifiable

            It 'Should have Set-TargetResource enable a resource' {
                Set-TargetResource -Cipher 'NULL' -Ensure Present
                Assert-MockCalled _SetCipher -ParameterFilter { $Cipher -eq 'NULL' -and $Enabled -eq '0xffffffff' }
            }

            It 'Should have Set-TargetResource disable a resource' {
                Set-TargetResource -Cipher 'NULL' -Ensure Absent
                Assert-MockCalled _SetCipher -ParameterFilter { $Cipher -eq 'NULL' -and $Enabled -eq '0x0' }
            }
        }

        Context "Given a live environment" {
            It 'Should not throw if a cipher does not exist' {
                { Get-TargetResource -Cipher 'Harbinger' } | Should Not Throw
                { Test-TargetResource -Cipher 'Harbinger' } | Should Not Throw
            }

            It 'Should enable a resource' {
                try {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\TestCipher" -Force -Confirm:$false -ErrorAction SilentlyContinue
                    Test-TargetResource -Cipher 'TestCipher' -Ensure Present | Should Be $false
                    (Get-TargetResource -Cipher 'TestCipher').Enabled | Should Be $false
                    
                    Set-TargetResource -Cipher 'TestCipher' -Ensure Present

                    Test-TargetResource -Cipher 'TestCipher' -Ensure Present | Should Be $true
                    (Get-TargetResource -Cipher 'TestCipher').Enabled | Should Be $true

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\TestCipher" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            It 'Should disable a resource' {
                try {
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\TestCipher" -Force
                    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\TestCipher" -Name Enabled -Value 0xffffffff -PropertyType 'DWord' -Force

                    Test-TargetResource -Cipher 'TestCipher' -Ensure Present | Should Be $true
                    (Get-TargetResource -Cipher 'TestCipher').Enabled | Should Be $true
                    
                    Set-TargetResource -Cipher 'TestCipher' -Ensure Absent

                    Test-TargetResource -Cipher 'TestCipher' -Ensure Absent | Should Be $true
                    (Get-TargetResource -Cipher 'TestCipher').Enabled | Should Be $false

                } finally {
                    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\TestCipher" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
