. .\Commands.ps1
. .\Utils.ps1
. .\Init.ps1
. .\TestUtils.ps1

Describe 'sdk' {
    Context 'No posh-sdk dir available'{
        $Script:SDK_FORCE_OFFLINE = $true
        Mock-PSDK-Dir
        Remove-Item $global:PSDK_DIR -Recurse
        Mock Init-Posh-Sdk -verifiable
        Mock Init-Candidate-Cache -verifiable
        Mock Show-Help
        sdk

        It 'initalize posh-sdk' {
            Assert-VerifiableMocks
        }

        It 'prints help' {
            Assert-MockCalled Show-Help 1
        }

        Reset-PSDK-Dir
    }

    Context 'Posh-sdk dir available'{
        $Script:SDK_FORCE_OFFLINE = $true
        Mock-PSDK-Dir
        Mock Init-Posh-Sdk
        Mock Init-Candidate-Cache -verifiable
        Mock Show-Help
        sdk

        It 'initalize posh-sdk' {
            Assert-VerifiableMocks
        }

        It 'does not init again' {
            Assert-MockCalled Init-Posh-Sdk 0
        }

        It 'prints help' {
            Assert-MockCalled Show-Help 1
        }

    }

    Context 'posh-sdk is forced offline' {
        Mock-PSDK-DIR
        Mock Init-Candidate-Cache -verifiable
        Mock Check-Available-Broadcast
        Mock Show-Help -verifiable
        $Script:SDK_FORCE_OFFLINE = $true

        sdk

        It 'does not load broadcast message from api' {
            Assert-MockCalled Check-Available-Broadcast 0
        }

        It 'performs default command actions' {
            Assert-VerifiableMocks
        }

        Reset-PSDK-DIR
    }

    Context 'posh-sdk offline command called' {
        Mock-PSDK-DIR
        Mock Init-Candidate-Cache -verifiable
        Mock Check-Available-Broadcast
        Mock Set-Offline-Mode -verifiable
        $Script:SDK_FORCE_OFFLINE = $false

        sdk offline

        It 'does not load broadcast message from api' {
            Assert-MockCalled Check-Available-Broadcast 0
        }

        It 'performs offline command actions' {
            Assert-VerifiableMocks
        }

        Reset-PSDK-DIR
    }

    Context 'posh-sdk online and command i called' {
        Mock-Dispatcher-Test
        Mock Install-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.2' -and $InstallPath -eq '\bla' }

        sdk i grails 2.2.2 \bla

        It 'checks for new broadcast, inits the Candidate-Cache and calls install-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command install called' {
        Mock-Dispatcher-Test
        Mock Install-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.2' -and $InstallPath -eq '' }

        sdk install grails 2.2.2

        It 'checks for new broadcast, inits the Candidate-Cache and calls install-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command uninstall called' {
        Mock-Dispatcher-Test
        Mock Uninstall-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.2' }

        sdk uninstall grails 2.2.2

        It 'checks for new broadcast, inits the Candidate-Cache and calls uninstall-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command rm called' {
        Mock-Dispatcher-Test
        Mock Uninstall-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.1' }

        sdk rm grails 2.2.1

        It 'checks for new broadcast, inits the Candidate-Cache and calls uninstall-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command ls called' {
        Mock-Dispatcher-Test
        Mock List-Candidate-Versions -verifiable -parameterFilter { $Candidate -eq 'grails'  }

        sdk ls grails

        It 'checks for new broadcast, inits the Candidate-Cache and calls list-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command list called' {
        Mock-Dispatcher-Test
        Mock List-Candidate-Versions -verifiable -parameterFilter { $Candidate -eq 'grails'  }

        sdk list grails

        It 'checks for new broadcast, inits the Candidate-Cache and calls list-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command u called' {
        Mock-Dispatcher-Test
        Mock Use-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.1' }

        sdk u grails 2.2.1

        It 'checks for new broadcast, inits the Candidate-Cache and calls use-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command use called' {
        Mock-Dispatcher-Test
        Mock Use-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.1' }

        sdk use grails 2.2.1

        It 'checks for new broadcast, inits the Candidate-Cache and calls use-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command d called' {
        Mock-Dispatcher-Test
        Mock Set-Default-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.1' }

        sdk d grails 2.2.1

        It 'checks for new broadcast, inits the Candidate-Cache and calls default-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command default called' {
        Mock-Dispatcher-Test
        Mock Set-Default-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '2.2.1' }

        sdk default grails 2.2.1

        It 'checks for new broadcast, inits the Candidate-Cache and calls default-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command c called' {
        Mock-Dispatcher-Test
        Mock Show-Current-Version -verifiable -parameterFilter { $Candidate -eq 'grails'  }

        sdk c grails

        It 'checks for new broadcast, inits the Candidate-Cache and calls current-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command current called' {
        Mock-Dispatcher-Test
        Mock Show-Current-Version -verifiable -parameterFilter { $Candidate -eq 'grails'  }

        sdk current grails

        It 'checks for new broadcast, inits the Candidate-Cache and calls current-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command v called' {
        Mock-Dispatcher-Test
        Mock Show-Posh-Sdk-Version -verifiable

        sdk v

        It 'checks for new broadcast, inits the Candidate-Cache and calls version-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command version called' {
        Mock-Dispatcher-Test
        Mock Show-Posh-Sdk-Version -verifiable

        sdk version

        It 'checks for new broadcast, inits the Candidate-Cache and calls version-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command b called' {
        Mock-Dispatcher-Test
        Mock Show-Broadcast-Message -verifiable

        sdk b

        It 'checks for new broadcast, inits the Candidate-Cache and calls broadcast-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command broadcast called' {
        Mock-Dispatcher-Test
        Mock Show-Broadcast-Message -verifiable

        sdk broadcast

        It 'checks for new broadcast, inits the Candidate-Cache and calls broadcast-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command h called' {
        Mock-Dispatcher-Test
        Mock Show-Help -verifiable

        sdk h

        It 'checks for new broadcast, inits the Candidate-Cache and calls help-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command help called' {
        Mock-Dispatcher-Test
        Mock Show-Help -verifiable

        sdk help

        It 'checks for new broadcast, inits the Candidate-Cache and calls help-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command offline called' {
        Mock-Dispatcher-Test -Offline
        Mock Set-Offline-Mode -verifiable -parameterFilter { $Flag -eq 'enable' }

        sdk offline enable

        It 'checks for new broadcast, inits the Candidate-Cache and calls offline-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command selfupdate called' {
        Mock-Dispatcher-Test
        Mock Invoke-Self-Update -verifiable

        sdk selfupdate

        It 'checks for new broadcast, inits the Candidate-Cache and calls selfupdate-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }

    Context 'posh-sdk online and command flush called' {
        Mock-Dispatcher-Test
        Mock Flush-Cache -verifiable -parameterFilter { $DataType -eq 'version'  }

        sdk flush version

        It 'checks for new broadcast, inits the Candidate-Cache and calls flush-command' {
            Assert-VerifiableMocks
        }

        Reset-Dispatcher-Test
    }
}

Describe 'Install-Candidate-Version' {
    Context 'Remote Version already installed' {
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { '1.1.1' } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Is-Candidate-Version-Locally-Available { $true } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }

        It 'throw an error' {
            { Install-Candidate-Version grails 1.1.1 } | Should Throw
        }

        It 'process precondition checks' {
            Assert-VerifiableMocks
        }
    }

    Context 'Local Version already installed' {
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { throw 'error' } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Is-Candidate-Version-Locally-Available { $true } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }

        It 'throw an error' {
            { Install-Candidate-Version grails 1.1.1 \bla } | Should Throw
        }

        It 'process precondition checks' {
            Assert-VerifiableMocks
        }
    }

    Context 'Local path but version is remote available already installed' {
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { 1.1.1 } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }

        It 'throw an error' {
            { Install-Candidate-Version grails 1.1.1 \bla } | Should Throw
        }

        It 'process precondition checks' {
            Assert-VerifiableMocks
        }
    }

    Context 'Local version installation without defaulting' {
        $backupAutoAnswer = $Global:PSDK_AUTO_ANSWER
        $Global:PSDK_AUTO_ANSWER = $false
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { throw 'error' } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Is-Candidate-Version-Locally-Available { $false } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Install-Local-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' -and $LocalPath -eq '\bla' }
        Mock Read-Host { 'n' }
        Mock Set-Linked-Candidate-Version

        Install-Candidate-Version grails 1.1.1 \bla

        It 'installs the local version' {
            Assert-VerifiableMocks
        }

        It "does not set default" {
            Assert-MockCalled Set-Linked-Candidate-Version 0
        }

        $Global:PSDK_AUTO_ANSWER = $backupAutoAnswer
    }

    Context 'Local version installation with auto defaulting' {
        $backupAutoAnswer = $Global:PSDK_AUTO_ANSWER
        $Global:PSDK_AUTO_ANSWER = $true
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { throw 'error' } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Is-Candidate-Version-Locally-Available { $false } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Install-Local-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' -and $LocalPath -eq '\bla' }
        Mock Set-Linked-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Write-Output -verifiable

        Install-Candidate-Version grails 1.1.1 \bla

        It 'installs the local version' {
            Assert-VerifiableMocks
        }

        $Global:PSDK_AUTO_ANSWER = $backupAutoAnswer
    }

    Context 'Remote version installation with prompt defaulting' {
        $backupAutoAnswer = $Global:PSDK_AUTO_ANSWER
        $Global:PSDK_AUTO_ANSWER = $false
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Check-Candidate-Version-Available { '1.1.1' } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Is-Candidate-Version-Locally-Available { $false } -verifiable { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Install-Remote-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Read-Host { 'y' }
        Mock Set-Linked-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Write-Output -verifiable

        Install-Candidate-Version grails 1.1.1

        It 'installs the local version' {
            Assert-VerifiableMocks
        }

        $Global:PSDK_AUTO_ANSWER = $backupAutoAnswer
    }
}

Describe 'Uninstall-Candidate-Version' {
    Context 'No version is provided' {
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        It 'throws an error' {
            { Uninstall-Candidate-Version grails } | Should Throw
        }
    }

    Context 'To be uninstalled version is not installed' {
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Is-Candidate-Version-Locally-Available { $false } -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '24.3' }

        It 'throws an error' {
            { Uninstall-Candidate-Version grails 24.3 } | Should Throw
        }

        It 'checks candidate' {
            Assert-VerifiableMocks
        }
    }

    Context 'To be uninstalled Version is current version' {
        Mock-PSDK-Dir
        New-Item -ItemType Directory "$Global:PSDK_DIR\grails\24.3" | Out-Null
        Set-Linked-Candidate-Version grails 24.3

        It 'finds current-junction defined' {
            Test-Path "$Global:PSDK_DIR\grails\current" | Should Be $true
        }

        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Is-Candidate-Version-Locally-Available { $true } -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '24.3' }
        Mock Get-Current-Candidate-Version { '24.3' } -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable

        Uninstall-Candidate-Version grails 24.3

        It 'delete the current-junction' {
            Test-Path "$Global:PSDK_DIR\grails\current" | Should Be $false
        }

        It 'delete the version' {
            Test-Path "$Global:PSDK_DIR\grails\24.3" | Should Be $false
        }

        It "checks different preconditions correctly" {
            Assert-VerifiableMocks
        }

        Reset-PSDK-Dir
    }

    Context 'To be uninstalled version is installed' {
        Mock-PSDK-Dir
        New-Item -ItemType Directory "$Global:PSDK_DIR\grails\24.3" | Out-Null

        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Is-Candidate-Version-Locally-Available { $true } -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '24.3'}
        Mock Get-Current-Candidate-Version { $null } -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable

        Uninstall-Candidate-Version grails 24.3

        It 'delete the version' {
            Test-Path "$Global:PSDK_DIR\grails\24.3" | Should Be $false
        }

        It "checks different preconditions correctly" {
            Assert-VerifiableMocks
        }

        Reset-PSDK-Dir
    }
}

Describe 'List-Candidate-Versions' {
    Context 'if in online mode' {
        Mock-Online
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Version-List -verifiable -parameterFilter { $Candidate -eq 'grails' }

        List-Candidate-Versions grails

        It 'write the version list retrieved from api' {
            Assert-VerifiableMocks
        }
    }

    Context 'If in offline mode' {
        Mock-Offline
        Mock Check-Candidate-Present -verifiable -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Offline-Version-List -verifiable -parameterFilter { $Candidate -eq 'grails' }

        List-Candidate-Versions grails

        It 'write the version list based on local file structure' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Use-Candidate-Version' {
    Context 'If new use version is already used' {
        Mock Check-Candidate-Version-Available { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Get-Env-Candidate-Version { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable
        Mock Check-Candidate-Version-Locally-Available

        Use-Candidate-Version grails 1.1.1

        It 'changes nothing' {
            Assert-VerifiableMocks
        }

        It 'does not test candidate version' {
            Assert-MockCalled Check-Candidate-Version-Locally-Available 0
        }
    }

    Context 'If setting a different version as the current version to use' {
        Mock Check-Candidate-Version-Available { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Get-Env-Candidate-Version { '1.1.0' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable
        Mock Check-Candidate-Version-Locally-Available -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Set-Env-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }

        Use-Candidate-Version grails 1.1.1

        It 'perform the changes' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Set-Default-Version' {
    Context 'If new default is already default' {
        Mock Check-Candidate-Version-Available { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Get-Current-Candidate-Version { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable
        Mock Check-Candidate-Version-Locally-Available

        Set-Default-Version grails 1.1.1

        It 'changes nothing' {
            Assert-VerifiableMocks
        }

        It 'does not test candidate version' {
            Assert-MockCalled Check-Candidate-Version-Locally-Available 0
        }
    }

    Context 'If setting a new default' {
        Mock Check-Candidate-Version-Available { '1.1.1' } -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Get-Current-Candidate-Version { '1.1.0' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable
        Mock Check-Candidate-Version-Locally-Available -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }
        Mock Set-Linked-Candidate-Version -verifiable -parameterFilter { $Candidate -eq 'grails' -and $Version -eq '1.1.1' }

        Set-Default-Version grails 1.1.1

        It 'perform the changes' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Show-Current-Version' {
    Context 'If called without candidate' {
        $Script:SDK_CANDIDATES = @('grails','groovy','bla')
        Mock Get-Env-Candidate-Version { '1.1.0' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Get-Env-Candidate-Version { '2.1.0' } -parameterFilter { $Candidate -eq 'groovy' }
        Mock Get-Env-Candidate-Version { '0.1.0' } -parameterFilter { $Candidate -eq 'bla' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'Using:' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'grails: 1.1.0' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'groovy: 2.1.0' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'bla: 0.1.0' }

        Show-Current-Version

        It 'write the version for all currently used candidates' {
            Assert-VerifiableMocks
        }
    }

    Context 'If called with specifiv candidate and version available' {
        Mock Check-Candidate-Present -verifiable
        Mock Get-Env-Candidate-Version { '1.1.0' } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'Using grails version 1.1.0' }

        Show-Current-Version grails

        It 'write version info' {
            Assert-VerifiableMocks
        }
    }

    Context 'If called with specifiv candidate and no version available' {
        Mock Check-Candidate-Present -verifiable
        Mock Get-Env-Candidate-Version { $null } -parameterFilter { $Candidate -eq 'grails' }
        Mock Write-Output -verifiable -parameterFilter { $InputObject -eq 'Not using any version of grails' }

        Show-Current-Version grails

        It 'write no version is available' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Show-Posh-Sdk-Version' {
    Context 'When called' {
        Mock Get-SDK-API-Version -verifiable
        Mock Get-Posh-Sdk-Version -verifiable
        Mock Write-Output -verifiable

        Show-Posh-Sdk-Version

        It 'write the version message to output' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Show-Broadcast-Message' {
    Context 'When called' {
        $Script:PSDK_BROADCAST_PATH = 'broadcast'
        Mock Get-Content { 'broadcast' } -verifiable -parameterFilter { $Path -eq 'broadcast' }
        Mock Write-Output -verifiable

        Show-Broadcast-Message

        It 'Write broadcast message to output' {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Set-Offline-Mode' {
    Context 'If called with invalid flag' {
        It 'throws an error' {
            { Set-Offline-Mode invalid } | Should Throw
        }
    }

    Context 'If called with enable flag' {
        $Script:SDK_FORCE_OFFLINE = $false
        Mock Write-Output -verifiable

        Set-Offline-Mode enable

        It "set offline mode" {
            $Script:SDK_FORCE_OFFLINE | Should Be $true
        }

        It "writes info to output" {
            Assert-VerifiableMocks
        }
    }

    Context 'if called with disable flag' {
        $Script:SDK_ONLINE = $false
        $Script:SDK_FORCE_OFFLINE = $true
        Mock Write-Output -verifiable

        Set-Offline-Mode disable

        It "deactivate offline mode" {
            $Script:SDK_FORCE_OFFLINE | Should Be $false
        }

        It "set sdk to online" {
            $Script:SDK_ONLINE | Should Be $true
        }

        It "writes info to output" {
            Assert-VerifiableMocks
        }
    }
}

Describe 'Flush-Cache' {
    Context 'Try to delete existing candidates cache' {
        $Script:PSDK_CANDIDATES_PATH = 'test'
        Mock Test-Path { $true } -parameterFilter { $Path -eq 'test' }
        Mock Remove-Item -verifiable -parameterFilter { $Path -eq 'test' }
        Mock Write-Output -verifiable

        Flush-Cache candidates

        It 'deletes the file and writes flush message' {
            Assert-VerifiableMocks
        }
    }

    Context 'Try to delete non-existing candidates cache' {
        $Script:PSDK_CANDIDATES_PATH = 'test2'
        Mock Test-Path { $false } -parameterFilter { $Path -eq 'test2' }
        Mock Write-Warning -verifiable

        Flush-Cache candidates

        It 'writes warning about non existing file' {
            Assert-VerifiableMocks
        }
    }

    Context 'Try to delete existing broadcast cache' {
        $Script:PSDK_BROADCAST_PATH = 'test'
        Mock Test-Path { $true } -parameterFilter { $Path -eq 'test' }
        Mock Remove-Item -verifiable -parameterFilter { $Path -eq 'test' }
        Mock Write-Output -verifiable

        Flush-Cache broadcast

        It 'deletes the file and writes flush message' {
            Assert-VerifiableMocks
        }
    }

    Context 'Try to delete non-existing broadcast cache' {
        $Script:PSDK_BROADCAST_PATH = 'test2'
        Mock Test-Path { $false } -parameterFilter { $Path -eq 'test2' }
        Mock Write-Warning -verifiable

        Flush-Cache broadcast

        It 'writes warning about non existing file' {
            Assert-VerifiableMocks
        }
    }

    Context 'Try to delete existing version cache' {
        $Script:SDK_API_VERSION_PATH = 'test'
        Mock Test-Path { $true } -parameterFilter { $Path -eq 'test' }
        Mock Remove-Item -verifiable -parameterFilter { $Path -eq 'test' }
        Mock Write-Output -verifiable

        Flush-Cache version

        It 'deletes the file and writes flush message' {
            Assert-VerifiableMocks
        }
    }

    Context 'Try to delete non-existing version cache' {
        $Script:SDK_API_VERSION_PATH = 'test2'
        Mock Test-Path { $false } -parameterFilter { $Path -eq 'test2' }
        Mock Write-Warning -verifiable

        Flush-Cache version

        It 'writes warning about non existing file' {
            Assert-VerifiableMocks
        }
    }

    Context 'Cleanup archives directory' {
        $Script:PSDK_ARCHIVES_PATH = 'archives'
        Mock Cleanup-Directory -verifiable -parameterFilter { $Path -eq  'archives' }

        Flush-Cache archives

        It 'cleanup archives directory' {
            Assert-VerifiableMocks
        }
    }

    Context 'Cleanup temp directory' {
        $Script:PSDK_TEMP_PATH = 'temp'
        Mock Cleanup-Directory -verifiable -parameterFilter { $Path -eq  'temp' }

        Flush-Cache temp

        It 'cleanup temp directory' {
            Assert-VerifiableMocks
        }
    }

    Context 'Cleanup tmp directory' {
        $Script:PSDK_TEMP_PATH = 'temp'
        Mock Cleanup-Directory -verifiable -parameterFilter { $Path -eq  'temp' }

        Flush-Cache tmp

        It 'cleanup temp directory' {
            Assert-VerifiableMocks
        }
    }

    Context 'flush invalid parameter' {
        It 'throws an error' {
            { Flush-Cache invalid } | Should Throw
        }
    }
}

Describe 'Show-Help' {
    Context 'If Show-Help is called' {
        Mock Write-Output -verifiable

        Show-Help

        It 'write the help to the output' {
            Assert-VerifiableMocks
        }
    }
}
