# Directory objects — OU tree and group inventory

Design rationale in [`../docs/02-directory-design.md`](../docs/02-directory-design.md).

## Organizational units

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

12 OUs total.

## Security groups

| Group | Scope | Members | Grants access to |
|---|---|---|---|
| GG-AdminStaff | Global | 4 | Administrative systems (Admin-Staff OU) |
| GG-Billing | Global | 1 | Billing / clearinghouse systems |
| GG-ClinicalCarts | Global | — | Shared clinical device/cart access (PPT-Shared-Devices) |
| GG-FrontDesk | Global | 3 | Scheduling and front-desk systems |
| GG-OfficeMgmt | Global | 1 | Office management functions |
| GG-Therapists | Global | 12 | EHR / clinical systems |

6 custom groups (5 role-based + 1 device-based); 12 total security groups
synced to Entra ID overall — the other 6 are non-critical default AD groups
(`ADSyncAdmins`, `ADSyncBrowse`, `ADSyncOperators`, `ADSyncPasswordSet`,
`DnsAdmins`, `DnsUpdateProxy`). Full export:
[`../evidence/03-security-groups.png`](../evidence/03-security-groups.png).

## User roster by role

| Role | Count | Primary group | OU |
|---|---|---|---|
| Therapist (PT/OT) | 12 | GG-Therapists | Therapists |
| Administrative | 4 | GG-AdminStaff | Admin-Staff |
| Front desk | 3 | GG-FrontDesk | Front-Desk |
| Billing | 1 | GG-Billing | Billing |
| Office manager | 1 | GG-OfficeMgmt | Office-Management |

> Names in the roster are synthetic. Listing them is optional — the role
> distribution is what demonstrates the design.
