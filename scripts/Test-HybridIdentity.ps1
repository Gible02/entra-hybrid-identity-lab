<#
.SYNOPSIS
    Validates the on-premises side of the hybrid identity deployment: object
    counts, source anchor coverage, and the sync service account.

.DESCRIPTION
    Source anchor coverage is the strongest single signal that synchronization is
    working. When Entra Connect links an on-premises object to its cloud
    counterpart, it writes mS-DS-ConsistencyGuid back into Active Directory.
    A user missing that attribute has not been linked.

    Compare the counts this reports against the Entra admin center. Every
    difference should have a named cause — see docs/06-validation.md.

.NOTES
    Part of the hybrid-identity-lab portfolio project.
    Run on PPT-DC01 in an elevated PowerShell session.
#>

[CmdletBinding()]
param(
    [string]$SearchBase = 'DC=peachpoint,DC=local'
)

Import-Module ActiveDirectory -ErrorAction Stop

function Write-Section($Title) {
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan
}

# --- Object counts --------------------------------------------------------
Write-Section 'On-premises object counts'

$users   = @(Get-ADUser  -Filter * -SearchBase $SearchBase -Properties Enabled, 'mS-DS-ConsistencyGuid')
$groups  = @(Get-ADGroup -Filter { GroupCategory -eq 'Security' } -SearchBase $SearchBase -Properties isCriticalSystemObject)
$ous     = @(Get-ADOrganizationalUnit -Filter * -SearchBase $SearchBase)

$syncableGroups = @($groups | Where-Object { -not $_.isCriticalSystemObject })

[pscustomobject]@{
    'Users (total)'        = $users.Count
    'Users (enabled)'      = @($users | Where-Object Enabled).Count
    'Users (disabled)'     = @($users | Where-Object { -not $_.Enabled }).Count
    'Security groups'      = $groups.Count
    'Groups eligible sync' = $syncableGroups.Count
    'Organizational units' = $ous.Count
} | Format-List

# --- Source anchor coverage ----------------------------------------------
Write-Section 'Source anchor coverage (mS-DS-ConsistencyGuid)'

$linked   = @($users | Where-Object { $_.'mS-DS-ConsistencyGuid' })
$unlinked = @($users | Where-Object { -not $_.'mS-DS-ConsistencyGuid' })

Write-Host "Linked to Entra ID : $($linked.Count)" -ForegroundColor Green
Write-Host "Not linked         : $($unlinked.Count)" -ForegroundColor $(if ($unlinked.Count) { 'Yellow' } else { 'Green' })

if ($unlinked.Count -gt 0) {
    Write-Host "`nUsers without a source anchor:" -ForegroundColor Yellow
    $unlinked | Select-Object SamAccountName, DistinguishedName | Format-Table -AutoSize
    Write-Host 'These have not synced. Check OU filtering, then force a delta cycle.' -ForegroundColor DarkGray
}

# --- Sync service account -------------------------------------------------
Write-Section 'Directory synchronization service account'

$msol = @(Get-ADUser -Filter { SamAccountName -like 'MSOL_*' } -Properties Created, Enabled)
if ($msol.Count -eq 0) {
    Write-Warning 'No MSOL_ account found. Entra Connect may not have completed setup against this forest.'
} else {
    $msol | Select-Object SamAccountName, Enabled, Created | Format-Table -AutoSize
}

# --- Recycle Bin ----------------------------------------------------------
Write-Section 'AD Recycle Bin'

$rb = Get-ADOptionalFeature -Filter { Name -like 'Recycle Bin Feature' }
if ($rb.EnabledScopes.Count -gt 0) {
    Write-Host 'Enabled.' -ForegroundColor Green
} else {
    Write-Warning 'NOT enabled. Run scripts/Enable-RecycleBin.ps1 — see docs/08-roadmap.md.'
}

Write-Host "`nCompare these counts against the Entra admin center. See docs/06-validation.md.`n" -ForegroundColor DarkGray
