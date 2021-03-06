﻿function Write-Offline-Broadcast() {
    Write-Output @"
==== BROADCAST =================================================================

OFFLINE MODE ENABLED! Some functionality is now disabled.

================================================================================
"@
}

function Write-Online-Broadcast() {
    Write-Output @"
==== BROADCAST =================================================================

ONLINE MODE RE-ENABLED! All functionality now restored.

================================================================================

"@
}

function Write-New-Version-Broadcast() {
    if ( $Script:SDK_API_NEW_VERSION -or $Script:PSDK_NEW_VERSION ) {
Write-Output @"
==== UPDATE AVAILABLE ==========================================================

A new version is available. Please consider to execute:

    sdk selfupdate

================================================================================
"@
    }
}

function Check-SDK-API-Version() {
    Write-Verbose 'Checking SDK-API version'
    try {
        $apiVersion = Get-SDK-API-Version
        $sdkRemoteVersion = Invoke-API-Call "broker/version"

        if ( $sdkRemoteVersion -gt $apiVersion) {
            if ( $Global:PSDK_AUTO_SELFUPDATE ) {
                Invoke-Self-Update
            } else {
                $Script:SDK_API_NEW_VERSION = $true
            }
        }
    } catch {
        $Script:SDK_AVAILABLE = $false
    }
}

function Check-Posh-Sdk-Version() {
    Write-Verbose 'Checking posh-sdk version'
    if ( Is-New-Posh-SDK-Version-Available ) {
        if ( $Global:PSDK_AUTO_SELFUPDATE ) {
            Invoke-Self-Update
        } else {
            $Script:PSDK_NEW_VERSION = $true
        }
    }
}

function Get-Posh-Sdk-Version() {
    return Get-Content $Script:PSDK_VERSION_PATH
}

function Is-New-Posh-SDK-Version-Available() {
    try {
        $localVersion = (Get-Posh-Sdk-Version).Trim()
        $currentVersion = (Invoke-RestMethod $Script:PSDK_VERSION_SERVICE).Trim()

        Write-Verbose "posh-sdk version check $currentVersion > $localVersion = $($currentVersion -gt $localVersion)"

        return ( $currentVersion -gt $localVersion )
    } catch {
        return $false
    }
}

function Get-SDK-API-Version() {
	if ( !(Test-Path $Script:SDK_API_VERSION_PATH) ) {
		return $null
	}
    return Get-Content $Script:SDK_API_VERSION_PATH
}

function Check-Available-Broadcast($Command) {
    $version = Get-SDK-API-Version
    if ( !( $version ) ) {
        return
    }

    $liveBroadcast = Invoke-Broadcast-API-Call

	Write-Verbose "Online-Mode: $Script:SDK_AVAILABLE"

	if ( $Script:SDK_ONLINE -and !($Script:SDK_AVAILABLE) ) {
		Write-Offline-Broadcast
	} elseif ( !($Script:SDK_ONLINE) -and $Script:SDK_AVAILABLE ) {
		Write-Online-Broadcast
	}
	$Script:SDK_ONLINE = $Script:SDK_AVAILABLE

	if ( $liveBroadcast ) {
		Handle-Broadcast $Command $liveBroadcast
	}
}

function Invoke-Broadcast-API-Call {
    try {
        $target = "$Script:PSDK_BROADCAST_SERVICE/broadcast/latest"
        Write-Verbose "Broadcast API call to: $target"
        return Invoke-RestMethod $target
    } catch {
        Write-Verbose "Could not reached broadcast API"
        $Script:SDK_AVAILABLE = $false
        return $null
    }
}

function Invoke-Self-Update($Force) {
    Write-Verbose 'Perform Invoke-Self-Update'
    Write-Output 'Update list of available candidates...'
    Update-Candidates-Cache
    $Script:SDK_API_NEW_VERSION = $false
    if ( $Force ) {
        Invoke-Posh-Sdk-Update
    } else {
        if ( Is-New-Posh-SDK-Version-Available ) {
            Invoke-Posh-Sdk-Update
        }
    }
    $Script:PSDK_NEW_VERSION = $false
}

function Invoke-Posh-Sdk-Update {
    Write-Output 'Update posh-sdk...'
    . "$psScriptRoot\GetPoshSdkMan.ps1"
}

function Check-Candidate-Present($Candidate) {
    if ( !($Candidate) ) {
        throw 'No candidate provided.'
    }

    if ( !($Script:SDK_CANDIDATES -contains $Candidate) ) {
        throw "Stop! $Candidate is no valid candidate!"
    }
}

function Check-Version-Present($Version) {
    if ( !($Version)) {
        throw 'No version provided.'
    }
}

function Check-Candidate-Version-Available($Candidate, $Version) {
    Check-Candidate-Present $Candidate

    $UseDefault = $false
    if ( !($Version) ) {
        Write-Verbose 'No version provided. Fallback to default version!'
        $UseDefault = $true
    }

    # Check locally
    elseif ( Is-Candidate-Version-Locally-Available $Candidate $Version ) {
        return $Version
    }

    # Check if offline
    if ( ! (Get-Online-Mode) ) {
        if ( $UseDefault ) {
            $Version = Get-Current-Candidate-Version $Candidate
            if ( $Version ) {
                return $Version
            } else {
                throw "Stop! No local default version for $Candidate and in offline mode."
            }
        }

        throw "Stop! $Candidate $Version is not available in offline mode."
    }

    if ( $UseDefault ) {
        Write-Verbose 'Try to get default version from remote'
        return Invoke-API-Call "/candidates/default/$Candidate"
    }

    $VersionAvailable = Invoke-API-Call "/candidates/validate/$Candidate/$Version/MINGW64"

    if ( $VersionAvailable -eq 'valid' ) {
        return $Version
    } else {
        throw "Stop! $Version is not a valid $Candidate version."
    }
}

function Get-Current-Candidate-Version($Candidate) {
    $currentLink = "$Global:PSDK_DIR\$Candidate\current"

    $targetItem = Get-Junction-Target $currentLink

    if ($targetItem) {
        return $targetItem.Name
    }

    return $null
}

function Get-Junction-Target($linkPath) {
    if ( Test-Path $linkPath ) {
        try {
            $linkItem = Get-Item $linkPath

            if (Get-Member -InputObject $linkItem -Name "ReparsePoint") {
                return (Get-Item $linkItem.ReparsePoint.Target)
            }

            if (Get-Member -InputObject $linkItem -Name "Target") {
                return (Get-Item $linkItem.Target)
            }
        } catch {
            return $null
        }
    }

    return $null
}

function Get-Env-Candidate-Version($Candidate) {
    $envLink = [System.Environment]::GetEnvironmentVariable(([string]$Candidate).ToUpper() + "_HOME")

    if ( $envLink -match '(.*)current$' ) {
        Get-Current-Candidate-Version $Candidate
    } else {
        return (Get-Item $envLink).Name
    }
}

function Check-Candidate-Version-Locally-Available($Candidate, $Version) {
    if ( !(Is-Candidate-Version-Locally-Available $Candidate $Version) ) {
        throw "Stop! $Candidate $Version is not installed."
    }
}

function Is-Candidate-Version-Locally-Available($Candidate, $Version) {
    if ( $Version ) {
        return Test-Path "$Global:PSDK_DIR\$Candidate\$Version"
    } else {
        return $false
    }
}

function Get-Installed-Candidate-Version-List($Candidate) {
    return Get-ChildItem "$Global:PSDK_DIR\$Candidate" | ?{ $_.PSIsContainer -and $_.Name -ne 'current' } | Foreach { $_.Name }
}

function Set-Env-Candidate-Version($Candidate, $Version) {
    $candidateEnv = ([string]$candidate).ToUpper() + "_HOME"
    $candidateDir = "$Global:PSDK_DIR\$candidate"
    $candidateHome = "$candidateDir\$Version"
    $candidateBin = "$candidateHome\bin"

    if ( !([Environment]::GetEnvironmentVariable($candidateEnv) -eq $candidateHome) ) {
        [Environment]::SetEnvironmentVariable($candidateEnv, $candidateHome)
    }

    $env:PATH = "$candidateBin;$env:PATH"
}

function Set-Linked-Candidate-Version($Candidate, $Version) {
    $Link = "$Global:PSDK_DIR\$Candidate\current"
    $Target = "$Global:PSDK_DIR\$Candidate\$Version"
    Set-Junction-Via-Mklink $Link $Target
}

function Set-Junction-Via-Mklink($Link, $Target) {
    if ( Test-Path $Link ) {
        (Get-Item $Link).Delete()
    }

    Invoke-Expression -Command "cmd.exe /c mklink /J '$Link' '$Target'" | Out-Null
}

function Get-Online-Mode() {
    return $Script:SDK_AVAILABLE -and ! ($Script:SDK_FORCE_OFFLINE)
}

function Check-Online-Mode() {
    if ( ! (Get-Online-Mode) ) {
        throw 'This command is not available in offline mode.'
    }
}

function Invoke-API-Call([string]$Path, [string]$FileTarget, [switch]$IgnoreFailure) {
    Write-Verbose "Calling $Path"
    try {
        $target = "$Script:PSDK_SERVICE/$Path"

        if ( $FileTarget ) {
            return Invoke-RestMethod $target -OutFile $FileTarget
        }

        return Invoke-RestMethod $target
    } catch {
        #TODO Check whether we would be better off just throwing an error here.
        $Script:SDK_AVAILABLE = $false
        if ( ! ($IgnoreFailure) ) {
            Check-Online-Mode
        } else {
			return $null
		}
    }
}

function Cleanup-Directory($Path) {
    $dirStats = Get-ChildItem $Path -Recurse | Measure-Object -property length -sum
    Remove-Item -Force -Recurse $Path
    $count = $dirStats.Count
    $size = $dirStats.Sum/(1024*1024)
    Write-Output "$count archive(s) flushed, freeing $size MB"
}

function Handle-Broadcast($Command, $Broadcast) {
    $oldBroadcast = $null
    if (Test-Path $Script:PSDK_BROADCAST_PATH) {
        $oldBroadcast = (Get-Content $Script:PSDK_BROADCAST_PATH) -join "`n"
        Write-Verbose 'Old broadcast message loaded'
    }

    if ($oldBroadcast -ne $Broadcast -and !($Command -match 'b(roadcast)?') -and $Command -ne 'selfupdate' -and $Command -ne 'flush' ) {
        Write-Verbose 'Showing the new broadcast message'
        Set-Content $Script:PSDK_BROADCAST_PATH $Broadcast
        Write-Output $Broadcast
    }
}

function Init-Candidate-Cache() {
    if ( !(Test-Path $Script:PSDK_CANDIDATES_PATH) ) {
        throw 'Can not retrieve list of candidates'
    }

    $Script:SDK_CANDIDATES = (Get-Content $Script:PSDK_CANDIDATES_PATH).Split(',')
    Write-Verbose "Available candidates: $Script:SDK_CANDIDATES"
}

function Update-Candidates-Cache() {
    Write-Verbose 'Update candidates-cache from SDK-API'
    Check-Online-Mode
    $version = Invoke-Api-Call 'broker/version'
    Set-Content -Path $Script:SDK_API_VERSION_PATH -Value $version.appVersion
    Invoke-API-Call 'candidates/all' $Script:PSDK_CANDIDATES_PATH
}

function Check-Candidate-Cache() {
    $updateTime = ((Get-Item $Script:PSDK_CANDIDATES_PATH).LastAccessTime).AddDays(30);
    if ((Test-Path $Script:PSDK_CANDIDATES_PATH) -and (Get-Content $Script:PSDK_CANDIDATES_PATH).Length -gt 0 -and (Get-Date) -gt $updateTime) {
        Write-Output 'WARNING: Posh-sdk is out-of-date and requires an update. Please run:'
        Write-Output ''
        Write-Output '  $ sdk update'
        Write-Output ''
        return 0
    } elseif ((Test-Path $Script:PSDK_CANDIDATES_PATH) -AND (Get-Content $Script:PSDK_CANDIDATES_PATH).Length -le 0) {
        Write-Output "Warning: Cache is corrupt. Posh-SDK can not be used until updated."
        Write-Output ''
        Write-Output '  $ sdk update'
        Write-Output ''
        return 1
    } else {
        Write-Debug "Posh-SDK: No update needed. Using existing candidates cache: $Script:PSDK_CANDIDATES_PATH"
        return 0
    }
}

function Write-Offline-Version-List($Candidate) {
    Write-Verbose 'Get version list from directory'

    Write-Output '------------------------------------------------------------'
    Write-Output "Offline Mode: only showing installed ${Candidate} versions"
    Write-Output '------------------------------------------------------------'
    Write-Output ''

    $current = Get-Current-Candidate-Version $Candidate
    $versions = Get-Installed-Candidate-Version-List $Candidate

    if ($versions) {
        foreach ($version in $versions) {
            if ($version -eq $current) {
                Write-Output " > $version"
            } else {
                Write-Output " * $version"
            }
        }
    } else {
        Write-Output '    None installed!'
    }

    Write-Output '------------------------------------------------------------'
	Write-Output '* - installed                                               '
	Write-Output '> - currently in use                                        '
	Write-Output '------------------------------------------------------------'
}

function Write-Version-List($Candidate) {
    Write-Verbose 'Get version list from API'

    $current = Get-Current-Candidate-Version $Candidate
    $versions = (Get-Installed-Candidate-Version-List $Candidate) -join ','
    Invoke-API-Call "candidates/$Candidate/MINGW64/versions/list?current=$current&installed=$versions" | Write-Output
}

function Install-Local-Version($Candidate, $Version, $LocalPath) {
    $dir = Get-Item $LocalPath

    if ( !(Test-Path $dir -PathType Container) ) {
        throw "Local installation path $LocalPath is no directory"
    }

    Write-Output "Linking $Candidate $Version to $LocalPath"
    $link = "$Global:PSDK_DIR\$Candidate\$Version"
    Set-Junction-Via-Mklink $link $LocalPath
    Write-Output "Done installing!"
}

function Install-Remote-Version($Candidate, $Version) {

    if ( !(Test-Path $Script:PSDK_ARCHIVES_PATH) ) {
        New-Item -ItemType Directory $Script:PSDK_ARCHIVES_PATH | Out-Null
    }

    $archive = "$Script:PSDK_ARCHIVES_PATH\$Candidate-$Version.zip"
    if ( Test-Path $archive ) {
        Write-Output "Found a previously downloaded $Candidate $Version archive. Not downloading it again..."
    } else {
		Check-Online-Mode
        Write-Output "`nDownloading: $Candidate $Version`n"
        Download-File "$Script:PSDK_SERVICE/broker/download/$Candidate/$Version/MINGW64" $archive
    }

    Write-Output "Installing: $Candidate $Version"

    # create temp dir if necessary
    if ( !(Test-Path $Script:PSDK_TEMP_PATH) ) {
        Write-Verbose "Temp dir does not exist."
        New-Item -ItemType Directory $Script:PSDK_TEMP_PATH | Out-Null
    }

    # unzip downloaded archive
    Write-Verbose "Preparing to unzip archive."
    $timestring = (Get-Date).ToFileTimeUtc()
    $tmpdir = "$Script:PSDK_TEMP_PATH\$timestring"
    Unzip-Archive $archive $tmpdir

	# check if unzip successfully
	# if ( !(Test-Path "$Script:PSDK_TEMP_PATH\*-$Version") ) {
    #     Write-Verbose "Could not detect archive."
	# 	throw "Could not unzip the archive of $Candidate $Version. Please delete archive from $Script:PSDK_ARCHIVES_PATH (or delete all with 'sdk flush archives')"
	# }

    # move to target location
    # Move was replaced by copy and remove because of random access denied errors
    # when Unzip was done by via -com shell.application
    # Move-Item "$Script:PSDK_TEMP_PATH\*-$Version" "$Global:PSDK_DIR\$Candidate\$Version"
    $directory = (Get-ChildItem $tmpdir).Name
    Copy-Item "$tmpdir\$directory\" "$Global:PSDK_DIR\$Candidate\$Version" -Recurse
    Remove-Item "$tmpdir" -Recurse -Force
    Write-Output "Done installing!"
}

function Unzip-Archive($Archive, $Target) {
    Write-Verbose "Unzipping archive $archive"
    $shellVersion = [int]::Parse($PSVersionTable.PSVersion.Major)
    if ( $shellVersion -gt 4 ) {
        Expand-Archive -LiteralPath $Archive -DestinationPath $Target

        if ($? -ne $true) {
            Remove-Item $Target -Recurse -Force
            throw "Could not unzip the archive of $Candidate $Version. Please delete archive from $Script:PSDK_ARCHIVES_PATH (or delete all with 'sdk flush archives')"
        }
    } elseif ( $Script:SEVENZ_On_PATH ) {
        $zipProcess = Start-Process 7z.exe -ArgumentList "x -o`"$Target`" -y `"$Archive`"" -Wait -PassThru -NoNewWindow

        if ($zipProcess.ExitCode -ne 0) {
            Remove-Item $Target -Recurse -Force
            throw "Could not unzip the archive of $Candidate $Version. Please delete archive from $Script:PSDK_ARCHIVES_PATH (or delete all with 'sdk flush archives')"
        }
    } elseif ( $Script:UNZIP_ON_PATH ) {
        unzip.exe -oq $Archive -d $Target
    } else {
        # use the windows shell as general fallback (no working on Windows Server Core because there is no shell)
        $shell = New-Object -com shell.application
        $shell.namespace($Target).copyhere($shell.namespace($Archive).items(), 0x10)
        # TODO: Handle failed unzip.
    }
}

function Download-File($Url, $TargetFile) {
	<#
		Adepted from http://blogs.msdn.com/b/jasonn/archive/2008/06/13/downloading-files-from-the-internet-in-powershell-with-progress.aspx
	#>
    Write-Verbose "Try to download $Url with HttpWebRequest"
	$uri = New-Object "System.Uri" $Url
    $request = [System.Net.HttpWebRequest]::Create($uri)
    [System.Net.ServicePointManager]::Expect100Continue = $true;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $request.set_Timeout(15000)
    $response = $request.GetResponse()
	$totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
	$responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
	$buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
	while ($count -gt 0)
    {
        if ($totalLength -lt 0) {
            $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
        }
        [System.Console]::CursorLeft = 0
        [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
    Write-Output ''
}
