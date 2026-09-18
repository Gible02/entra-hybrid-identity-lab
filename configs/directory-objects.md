# Directory objects — OU tree and group inventory

> **FILL IN** — export from `PPT-DC01` and paste below. Commands and design
> rationale are in [`../docs/02-directory-design.md`](../docs/02-directory-design.md).

## Organizational units

```
DC=peachpoint,DC=local
<!-- paste Get-ADOrganizationalUnit output -->
```

## Security groups

| Group | Scope | Members | Grants access to |
|---|---|---|---|
| | | | |

## User roster by role

| Role | Count | Primary group | OU |
|---|---|---|---|
| Therapist (PT/OT) | 12 | | |
| Administrative | 4 | | |
| Front desk | 3 | | |
| Billing | 1 | | |
| Office manager | 1 | | |

> Names in the roster are synthetic. Listing them is optional — the role
> distribution is what demonstrates the design.
