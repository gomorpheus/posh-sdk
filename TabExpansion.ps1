# Check if function TabExpansion already exists and backup existing version to
# prevent breaking other TabExpansion implementations.
# Taken from posh-git https://github.com/dahlbyk/posh-git/blob/master/GitTabExpansion.ps1#L297
$tabExpansionBackup = 'PoshSDK_DefaultTabExpansion'
if (Test-Path Function:\TabExpansion) {
    Rename-Item Function:\TabExpansion $tabExpansionBackup -ErrorAction SilentlyContinue
}

function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

    switch -regex ($lastBlock) {
        # Execute SDK tab expansion for SDK command
        '^SDK (.*)' { SDKTabExpansion($lastBlock) }
        # Fall back on existing tab expansion
        default { if (Test-Path Function:\$tabExpansionBackup) { & $tabExpansionBackup $line $lastWord } }
    }
}

$Script:PSDK_TAB_COMMANDS = @('install','uninstall','rm','list','use','default','current','version','broadcast','help','offline','selfupdate','flush')
function SDKTabExpansion($lastBlock) {
    if ( !($lastBlock -match '^SDK\s+(?<cmd>\S+)?(?<args> .*)?$') ) {
        return
    }
    $command = $Matches['cmd']
    $arguments = $Matches['args']

    if ( !($arguments) ) {
        # Try to complete the command
        return $Script:PSDK_TAB_COMMANDS | Where-Object { $_.StartsWith($command) }
    }

    $arguments = $arguments.TrimStart()
    # Help add correct parameters
    switch -regex ($command) {
        '^i(nstall)?'    { SDKTabExpandion-Need-Candidate $command $arguments }
        '^(uninstall|rm)'{ SDKTabExpandion-Need-Candidate $command $arguments }
        '^(ls|list)'     { SDKTabExpandion-Need-Candidate $command $arguments }
        '^u(se)?'        { SDKTabExpandion-Need-Candidate $command $arguments }
        '^d(efault)?'    { SDKTabExpandion-Need-Candidate $command $arguments }
        '^c(urrent)?'    { SDKTabExpandion-Need-Candidate $command $arguments }
        '^offline'       { SDKTabExpansion-Offline $arguments }
        '^flush'         { SDKTabExpansion-Flush $arguments }
        default          {}
    }
}

function SDKTabExpandion-Need-Candidate($Command, $LastBlock) {
    if ( !($LastBlock -match "^(?<candidate>\S+)?(?<args> .*)?$") ) {
        return
    }
    $candidate = $Matches['candidate']
    $arguments = $Matches['args']

    Init-Candidate-Cache

    if ( !($arguments) ) {
        # Try to complete the command
        return $Script:SDK_CANDIDATES | Where-Object { $_.StartsWith($candidate) }
    }

    if ( !($Script:SDK_CANDIDATES -contains $candidate) ) {
        return
    }

    $arguments = $arguments.TrimStart()
    # Help add correct parameters
    switch -regex ($command) {
        #'^i(nstall)?'    { SDKTabExpandion-Need-Version $candidate $arguments }
        '^(uninstall|rm)'{ SDKTabExpandion-Need-Version $candidate $arguments }
        '^u(se)?'        { SDKTabExpandion-Need-Version $candidate $arguments }
        '^d(efault)?'    { SDKTabExpandion-Need-Version $candidate $arguments }
        default          {}
    }
}

function SDKTabExpandion-Need-Version($Candidate, $LastBlock) {
    Get-Installed-Candidate-Version-List $Candidate | Where-Object { $_.StartsWith($LastBlock) }
}

function SDKTabExpansion-Offline($Arguments) {
    @('enable','disable') | Where-Object { ([string]$_).StartsWith($Arguments) }
}

function SDKTabExpansion-Flush($Arguments) {
    @('candidates','broadcast','archives','temp') | Where-Object { ([string]$_).StartsWith($Arguments) }
}

Export-ModuleMember TabExpansion
Export-ModuleMember SDKTabExpansion