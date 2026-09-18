# Entra Connect Sync — configuration reference

Every setting as chosen, in one place. Rationale in
[`../docs/04-design-decisions.md`](../docs/04-design-decisions.md).

## Connected directory

| Setting | Value |
|---|---|
| Directory type | Active Directory |
| Forest | `peachpoint.local` |
| Connector account | Auto-created (`MSOL_…`) |
| Creation credential | `PEACHPOINT\administrator` (Enterprise Admin, used once) |

## Sign-in

| Setting | Value |
|---|---|
| Method | Password Hash Synchronization |
| Seamless SSO | Not enabled |
| UPN attribute | `userPrincipalName` |
| UPN suffix verified | No — `peachpoint.local` is unverifiable |
| Continue without matched suffixes | Yes |

## Scope

| Setting | Value |
|---|---|
| Domain and OU filtering | Sync all domains and OUs |
| User and device filtering | Synchronize all users and devices |
| Group-based pilot scoping | Not used |

## Object matching

| Setting | Value |
|---|---|
| Cross-directory identification | Users represented only once |
| Source anchor | Managed by Azure — `mS-DS-ConsistencyGuid` |

## Optional features

| Feature | State |
|---|---|
| Password hash synchronization | **Enabled** |
| Exchange hybrid deployment | Disabled |
| Exchange Mail Public Folders | Disabled |
| Entra ID app and attribute filtering | Disabled |
| Password writeback | Disabled |
| Group writeback | Disabled |
| Device writeback | Disabled |
| Directory extension attribute sync | Disabled |

## Scheduler

Default: a delta sync every 30 minutes. Verify with `Get-ADSyncScheduler`.

## Exporting the live configuration

Entra Connect can export its full configuration to JSON for documentation or
disaster recovery:

**Entra Connect → View or export current configuration → Export Settings**

> The export contains tenant identifiers and connector details. It is excluded
> from this repo by `.gitignore` (`configs/exported/`). Sanitize before committing
> anything from it.
