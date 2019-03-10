<#
posh-sdk / POwerSHell Groovy enVironment Manager

https://github.com/gomorpheus/posh-sdk

Needed:
- Powershell 3.0 (For Windows 7 install Windows Management Framework 3.0)
#>

#region Config
if ( !(Test-Path Variable:Global:PSDK_DIR) ) {
	$Global:PSDK_DIR = "$env:USERPROFILE\.posh_sdk"
}
if ( !(Test-Path Variable:Global:PSDK_AUTO_ANSWER) ) {
	$Global:PSDK_AUTO_ANSWER = $false
}
if ( !(Test-Path Variable:Global:PSDK_AUTO_SELFUPDATE) ) {
	$Global:PSDK_AUTO_SELFUPDATE = $false
}

$Script:PSDK_INIT = $false
$Script:PSDK_SERVICE = 'https://api.sdkman.io/2'
$Script:PSDK_BROADCAST_SERVICE = 'https://api.sdkman.io/2'
$Script:SDK_BASE_VERSION = '1.3.13'

$Script:PSDK_CANDIDATES_PATH = "$Global:PSDK_DIR\.meta\candidates.txt"
$Script:PSDK_BROADCAST_PATH = "$Global:PSDK_DIR\.meta\broadcast.txt"
$Script:SDK_API_VERSION_PATH = "$Global:PSDK_DIR\.meta\version.txt"
$Script:PSDK_ARCHIVES_PATH = "$Global:PSDK_DIR\.meta\archives"
$Script:PSDK_TEMP_PATH = "$Global:PSDK_DIR\.meta\tmp"

$Script:SDK_API_NEW_VERSION = $false
$Script:PSDK_NEW_VERSION = $false
$Script:PSDK_VERSION_PATH = "$psScriptRoot\VERSION.txt"
$Script:PSDK_VERSION_SERVICE = "https://raw.githubusercontent.com/gomorpheus/posh-sdk/master/VERSION.txt"

$Script:SDK_AVAILABLE = $true
$Script:SDK_ONLINE = $true
$Script:SDK_FORCE_OFFLINE = $false
$Script:SDK_CANDIDATES = $null
$Script:FIRST_RUN = $true

$Script:UNZIP_ON_PATH = $false
#endregion

Push-Location $psScriptRoot
. .\Utils.ps1
. .\Commands.ps1
. .\Init.ps1
. .\TabExpansion.ps1
Pop-Location

Init-Posh-Sdk

Export-ModuleMember 'sdk'
