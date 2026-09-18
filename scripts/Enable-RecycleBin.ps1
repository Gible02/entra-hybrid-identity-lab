<#
.SYNOPSIS
    Enables the Active Directory Recycle Bin for the peachpoint.local forest.

.DESCRIPTION
    Checks whether the Recycle Bin optional feature is already enabled before
    attempting to enable it. Enabling the AD Recycle Bin is IRREVERSIBLE — the
    feature cannot be disabled once activated. That is by design.

    Without it, a deleted user or OU cannot be restored without a system state
    recovery of the domain controller.

    Requires: Enterprise Admin, forest functional level 2008 R2 or higher.

.NOTES
    Part of the hybrid-identity-lab portfolio project.
    Run on PPT-DC01 in an elevated PowerShell session.
#>

[CmdletBinding()]
param(
    [string]$ForestName = 'peachpoint.local'
)

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "`nForest: $ForestName" -ForegroundColor Cyan

# --- Forest functional level check ---------------------------------------
$forest = Get-ADForest -Identity $ForestName
Write-Host "Functional level: $($forest.ForestMode)"

if ($forest.ForestMode -lt 'Windows2008R2Forest') {
    Write-Warning 'Forest functional level is below 2008R2. Raise it before enabling the Recycle Bin.'
    return
}

# --- Already enabled? -----------------------------------------------------
$feature = Get-ADOptionalFeature -Filter { Name -like 'Recycle Bin Feature' }

if ($feature.EnabledScopes.Count -gt 0) {
    Write-Host 'Recycle Bin is already enabled. Nothing to do.' -ForegroundColor Green
    $feature | Select-Object Name, EnabledScopes | Format-List
    return
}

Write-Host 'Recycle Bin is NOT enabled.' -ForegroundColor Yellow
Write-Warning 'This operation cannot be undone. The feature cannot be disabled once enabled.'

$confirm = Read-Host 'Type ENABLE to proceed'
if ($confirm -cne 'ENABLE') {
    Write-Host 'Aborted. No changes made.' -ForegroundColor Yellow
    return
}

Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' `
    -Scope ForestOrConfigurationSet `
    -Target $ForestName `
    -Confirm:$false

Write-Host "`nEnabled. Verifying:" -ForegroundColor Green
Get-ADOptionalFeature -Filter { Name -like 'Recycle Bin Feature' } |
    Select-Object Name, EnabledScopes | Format-List
