<#
.SYNOPSIS
    Reports Microsoft Entra Connect Sync health: installed version, scheduler
    state, connectors, and current run status.

.DESCRIPTION
    Run on the server hosting Entra Connect Sync.

    The version check matters: Microsoft requires all Entra Connect Sync
    installations to run version 2.5.79.0 or later by 30 September 2026. Older
    builds stop synchronizing on that date.

.NOTES
    Part of the hybrid-identity-lab portfolio project.
    Run on PPT-DC01 in an elevated PowerShell session.
#>

[CmdletBinding()]
param()

$MinimumVersion = [version]'2.5.79.0'

function Write-Section($Title) {
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan
}

# --- Installed version ----------------------------------------------------
Write-Section 'Installed version'

$paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$install = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like '*Entra Connect*' -or $_.DisplayName -like '*Azure AD Connect*' } |
    Select-Object DisplayName, DisplayVersion -First 1

if (-not $install) {
    Write-Warning 'Entra Connect does not appear to be installed on this host.'
} else {
    Write-Host "$($install.DisplayName) — $($install.DisplayVersion)"

    try {
        $installed = [version]$install.DisplayVersion
        if ($installed -lt $MinimumVersion) {
            Write-Warning "Below the required minimum of $MinimumVersion."
            Write-Warning 'Installations below this version stop syncing after 30 September 2026. Upgrade.'
        } else {
            Write-Host "Meets the $MinimumVersion minimum." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Could not parse version string '$($install.DisplayVersion)'. Check manually."
    }
}

# --- ADSync module --------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name ADSync)) {
    Write-Warning 'ADSync module not available. Remaining checks skipped.'
    return
}

Import-Module ADSync -ErrorAction Stop

# --- Scheduler ------------------------------------------------------------
Write-Section 'Sync scheduler'
$sched = Get-ADSyncScheduler
$sched | Format-List AllowedSyncCycleInterval, CurrentlyEffectiveSyncCycleInterval,
                     NextSyncCyclePolicyType, NextSyncCycleStartTimeInUTC,
                     SyncCycleEnabled, StagingModeEnabled

if (-not $sched.SyncCycleEnabled) {
    Write-Warning 'Sync cycle is DISABLED. No automatic synchronization is occurring.'
}
if ($sched.StagingModeEnabled) {
    Write-Warning 'Staging mode is ENABLED. Changes are not being exported to Entra ID.'
}

# --- Connectors -----------------------------------------------------------
Write-Section 'Connectors'
Get-ADSyncConnector | Select-Object Name, Type | Format-Table -AutoSize

# --- Run status -----------------------------------------------------------
Write-Section 'Current run status'
$status = Get-ADSyncConnectorRunStatus
if ($status) { $status | Format-Table -AutoSize }
else { Write-Host 'Idle — no sync cycle currently running.' }

Write-Host "`nTo force a cycle:  Start-ADSyncSyncCycle -PolicyType Delta`n" -ForegroundColor DarkGray
