Import-Module -Name "$PSScriptRoot\..\DSCResources\CipherOrder"
InModuleScope 'CipherOrder' {
    Describe 'CipherOrder is a DSC Resource' {

        Context "Meets DSC syntax requirements" {
            It 'Should be syntactically correct' {
                $res = Test-xDscSchema -Path "$PSScriptRoot\..\DSCResources\CipherOrder\CipherOrder.schema.mof"
                $res | Should Be $true
            }

            It 'Should be a well formed resource' {
                $res = Test-xDscResource -Name "$PSScriptRoot\..\DSCResources\CipherOrder"

                $res | Should Be $true
            }
        }

        Context "Given a test order." {
            Mock _GetCipherOrder -MockWith {
                "A,B,C,D"
            }

            It 'Should have Get-TargetResource return the order.' {
                (Get-TargetResource -Ciphers "all").Ciphers -eq "A,B,C,D" | Should Be $true
            }

            It 'Should have Test-TargetResource return $true when the expected order matches.' {
                (Test-TargetResource -Ciphers "A,B,C,D") | Should Be $true
            }

            It 'Should have Test-TargetResource return $false when the expected cipher order does not match.' {
                Test-TargetResource -Ciphers "B,A,D,C" | Should Be $false
            }

        }

        Context "Given a live environment" {
            It 'Should not throw if a cipher order does not exist' {
                try {
                    $property = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name "Functions" -ErrorAction SilentlyContinue
                    Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name "Functions" -Force -Confirm:$false -ErrorAction SilentlyContinue
                    { Get-TargetResource -Ciphers "all" } | Should Not Throw
                    { Test-TargetResource -Ciphers "A,B,C,D" } | Should Not Throw
                } finally {
                    if ($property) {
                        Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name "Functions" -Value $property -ErrorAction SilentlyContinue
                    }
                }
            }

            It 'Should set the cipher order' {
                try {
                    Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name "Functions" -Force -Confirm:$false -ErrorAction SilentlyContinue
                    Test-TargetResource -Ciphers  "A,B,C,D" | Should Be $false
                    (Get-TargetResource -Ciphers "all").Ciphers | Should Be $false
                    
                    Set-TargetResource -Ciphers "A,B,C,D"

                    Test-TargetResource -Ciphers "A,B,C,D" | Should Be $true
                    (Get-TargetResource -Ciphers "all").Ciphers -eq "A,B,C,D" | Should Be $true

                } finally {
                    Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name "Functions" -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
