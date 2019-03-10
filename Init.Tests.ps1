. .\Utils.ps1
. .\Init.ps1
. .\TestUtils.ps1

Describe 'Init-Posh-Sdk' {
    Context 'PSDK-Dir with only a grails folder' {
        Mock-PSDK-Dir
        Mock Check-JAVA-HOME -verifiable
        Mock Update-Candidates-Cache -verifiable
        Mock Init-Candidate-Cache -verifiable
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq 'current' }
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'groovy' -and $Version -eq 'current' }
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'bla' -and $Version -eq 'current' }
        $Script:PSDK_CANDIDATES_PATH = "$Global:PSDK_DIR\.meta\candidates.txt"
        $Script:SDK_CANDIDATES = 'grails','groovy','bla'

        Init-Posh-Sdk

        It "creates .meta" {
            Test-Path "$Global:PSDK_DIR\.meta" | Should Be $true
        }

        It "creates grails" {
            Test-Path "$Global:PSDK_DIR\grails" | Should Be $true
        }

        It "creates groovy" {
            Test-Path "$Global:PSDK_DIR\groovy" | Should Be $true
        }

        It "creates bla" {
            Test-Path "$Global:PSDK_DIR\bla" | Should Be $true
        }

        It "calls methods to test JAVA_HOME, API version, loads candidate cache and setup env variables" {
            Assert-VerifiableMocks
        }

        Reset-PSDK-Dir
    }

    Context 'PSDK-Dir with only a grails folder and a candidates list' {
        Mock-PSDK-Dir
        Mock Check-JAVA-HOME -verifiable
        Mock Update-Candidates-Cache
        Mock Init-Candidate-Cache -verifiable
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq 'current' }
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'groovy' -and $Version -eq 'current' }
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'bla' -and $Version -eq 'current' }
        $Script:PSDK_CANDIDATES_PATH = "$Global:PSDK_DIR\.meta\candidates.txt"
        New-Item -ItemType Directory "$Global:PSDK_DIR\.meta" | Out-Null
        New-Item -ItemType File $Script:PSDK_CANDIDATES_PATH | Out-Null
        $Script:SDK_CANDIDATES = 'grails','groovy','bla'

        Init-Posh-Sdk

        It "creates .meta" {
            Test-Path "$Global:PSDK_DIR\.meta" | Should Be $true
        }

        It "creates grails" {
            Test-Path "$Global:PSDK_DIR\grails" | Should Be $true
        }

        It "creates groovy" {
            Test-Path "$Global:PSDK_DIR\groovy" | Should Be $true
        }

        It "creates bla" {
            Test-Path "$Global:PSDK_DIR\bla" | Should Be $true
        }

        It "calls methods to test JAVA_HOME, API version, loads candidate cache and setup env variables" {
            Assert-VerifiableMocks
        }

        It "does not call update-candidates-cache" {
            Assert-MockCalled Update-Candidates-Cache 0
        }

        Reset-PSDK-Dir
    }
}

Describe 'Check-JAVA-HOME' {
    Context 'JAVA_HOME is set' {
        Mock Get-Command
        Mock Test-Path { $true } -parameterFilter { $Path -eq 'env:Java_HOME' }

        Check-JAVA-HOME

        It "changes nothing" {
            Assert-MockCalled Get-Command 0
        }
    }

    Context 'JAVA_HOME is not set but javac is on path' {
        $backupJAVAHOME = [Environment]::GetEnvironmentVariable('JAVA_HOME')
        Mock Test-Path { $false } -parameterFilter { $Path -eq 'env:Java_HOME' }
        Mock Get-Command { New-Object PSObject -Property @{ Path = (Get-Item 'C:\Windows\explorer.exe') } } -parameterFilter { $Name -eq 'javac' }
        $expectedNewJAVAHOME = 'C:\'

        Check-JAVA-HOME

        It "sets JAVA_HOME to javac parent" {
            [Environment]::GetEnvironmentVariable('JAVA_HOME') | Should Be $expectedNewJAVAHOME
        }

        [Environment]::SetEnvironmentVariable('JAVA_HOME', $backupJAVAHOME)
    }

    Context 'JAVA_HOME is not set and javax is not on path' {
        Mock Test-Path { $false } -parameterFilter { $Path -eq 'env:Java_HOME' }
        Mock Get-Command { throw 'error' } -parameterFilter { $Name -eq 'javac' }

        It "throws an error" {
            { Check-JAVA-HOME } | Should Throw
        }
    }
}