# 02 — Directory design

## Exporting the real structure

On `PPT-DC01`, in an elevated PowerShell session:

```powershell
# OU tree
Get-ADOrganizationalUnit -Filter * -SearchBase "DC=peachpoint,DC=local" |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName |
    Format-Table -AutoSize

# Security groups with membership counts
Get-ADGroup -Filter { GroupCategory -eq "Security" } -SearchBase "DC=peachpoint,DC=local" -Properties Members |
    Select-Object Name, GroupScope, @{N='Members';E={ $_.Members.Count }} |
    Sort-Object Name |
    Format-Table -AutoSize

# User count per OU
Get-ADOrganizationalUnit -Filter * -SearchBase "DC=peachpoint,DC=local" | ForEach-Object {
    [pscustomobject]@{
        OU    = $_.Name
        Users = (Get-ADUser -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count
    }
} | Format-Table -AutoSize
```

## Design principles applied

The structure serves two targeting needs that pull in different directions.

**Group Policy targets naturally by location.** Printers, mapped drives, and
local security settings differ per clinic. A site-based OU structure makes GPO
linking straightforward.

**Access control targets naturally by role.** Under the minimum necessary
standard, a front desk employee and a billing specialist need different reach.
Role-based security groups make that expressible.

Structuring for only one of these makes the other painful, so the design does
both: **OUs carry location and administrative delegation; security groups carry
role and access.**

## OU structure

12 OUs total: a site tier for location-based GPO targeting and a role tier for
access-control targeting, exactly as the design principles above call for.

```
DC=peachpoint,DC=local
├── OU=PPT-Sites
│   ├── OU=North
│   ├── OU=South
│   └── OU=West
├── OU=PPT-Users
│   ├── OU=Admin-Staff
│   ├── OU=Billing
│   ├── OU=Front-Desk
│   ├── OU=Office-Management
│   └── OU=Therapists
├── OU=PPT-Shared-Devices
└── OU=PPT-Workstations
```

![OU structure in Active Directory Users and Computers](../evidence/02-ou-structure.png)

## Security groups

Each role OU carries one `GG-` (global group) scoped to that function, used to
grant role-based access rather than assigning permissions to individual users.
One additional group, `GG-ClinicalCarts`, covers a shared device resource
rather than a role:

| Group | Scope | OU | Purpose |
|---|---|---|---|
| GG-AdminStaff | Global | Admin-Staff | General admin staff |
| GG-Billing | Global | Billing | Billing staff — clearinghouse access |
| GG-ClinicalCarts | Global | PPT-Shared-Devices | Shared clinical device/cart access |
| GG-FrontDesk | Global | Front-Desk | Front desk staff — shared scheduling access |
| GG-OfficeMgmt | Global | Office-Management | Office manager |
| GG-Therapists | Global | Therapists | Roaming therapists — EHR access |

Entra ID reports **12 on-premises security groups synced** (see
[`06-validation.md`](06-validation.md)), which the verification query below
accounts for exactly: the 6 custom `GG-` groups above, plus 6 non-critical
default AD groups (`isCriticalSystemObject = False`) that are eligible to sync
under Entra Connect's default filtering rules — `ADSyncAdmins`,
`ADSyncBrowse`, `ADSyncOperators`, `ADSyncPasswordSet`, `DnsAdmins`, and
`DnsUpdateProxy`. Full output: [`03-security-groups.png`](../evidence/03-security-groups.png).

## User roster

21 staff accounts distributed across the role structure described in
[`01-scenario.md`](01-scenario.md):

| OU | Role | Count |
|---|---|---|
| Admin-Staff | Administrative | 4 |
| Billing | Billing | 1 |
| Front-Desk | Front desk | 3 |
| Office-Management | Office manager | 1 |
| Therapists | Physical / occupational therapist | 12 |
| **Total** | | **21** |

![Staff accounts in Active Directory Users and Computers](../evidence/04-user-roster.png)

## Verification note

Post-sync, Entra ID reported **12 on-premises groups**. Confirm that all 12 are
intentional design objects rather than incidental groups that synced without being
filtered. Groups marked `isCriticalSystemObject` (Domain Admins, Enterprise Admins
and similar) are excluded by Entra Connect's default rules, so any surplus is more
likely to be a group created during the build than a built-in.

```powershell
# Every non-critical security group that is eligible to sync
Get-ADGroup -Filter { GroupCategory -eq "Security" } -Properties isCriticalSystemObject |
    Where-Object { -not $_.isCriticalSystemObject } |
    Select-Object Name, DistinguishedName |
    Sort-Object Name
```
