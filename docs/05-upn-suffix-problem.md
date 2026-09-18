# 05 — What the `.local` domain suffix cost

The most instructive failure in this project was not a misconfiguration. It was a
decision made at forest-creation time whose consequences did not surface until
much later.

## What happened

`peachpoint.local` uses the `.local` top-level domain. At the **Microsoft Entra
sign-in configuration** step, Entra Connect reported the UPN suffix
`peachpoint.local` as **Not Added**, warning that users would be unable to sign
into Entra ID with their on-premises credentials.

![UPN suffix not added](../evidence/10-upn-suffix-warning.png)

## Why

Entra ID requires a UPN suffix to be matched to a **verified domain** — one whose
ownership is proven by publishing a DNS TXT record at the registrar.

`.local` is reserved and non-routable. Nobody can register it, so nobody can
publish a TXT record for it, so nobody can verify it. The requirement cannot be
satisfied, not merely unsatisfied.

Microsoft has recommended against `.local` for internal AD naming for years —
partly for exactly this reason, and partly because it collides with mDNS/Bonjour
on mixed-OS networks.

## The resolution in this lab

Checked **Continue without matching all UPN suffixes to verified domains**.

**Consequence:** accounts sync successfully, but their cloud UPNs fall back to the
tenant's `.onmicrosoft.com` domain. A user who is `jsmith@peachpoint.local` on
premises signs into the cloud as `jsmith@<tenant>.onmicrosoft.com`. The identities
are linked and the sync is functional; the sign-in name is simply not the on-premises
one.

For a lab demonstrating synchronization mechanics, that is an acceptable and
well-understood limitation.

## The resolution in production

Neither option is a checkbox.

### Option 1 — Add an alternative UPN suffix

1. Register a routable domain the organization actually owns
   (`peachpointtherapy.com`).
2. Add it as a custom domain in Entra ID and verify it via DNS TXT record.
3. In **Active Directory Domains and Trusts**, right-click the root →
   *Properties* → *UPN Suffixes* → add `peachpointtherapy.com`.
4. Re-stamp user UPNs to the new suffix:

   ```powershell
   Get-ADUser -Filter * -SearchBase "OU=Staff,DC=peachpoint,DC=local" -Properties UserPrincipalName |
       ForEach-Object {
           $new = $_.SamAccountName + "@peachpointtherapy.com"
           Set-ADUser -Identity $_ -UserPrincipalName $new
       }
   ```

   Test against a single account before running against the roster.
5. Run a full sync cycle and confirm cloud UPNs updated.

On-premises DNS keeps using `.local`. Sign-in identity uses the routable name.
The two are decoupled, which is the point.

### Option 2 — Name the forest correctly from the outset

A subdomain of a domain the organization owns — `corp.peachpointtherapy.com`.
This is the current recommended practice and avoids the problem entirely.

## Why this is the most valuable thing in the project

The cost of the naming decision was **invisible for the entire build** and only
appeared at integration. Nothing during forest promotion, OU creation, user
provisioning, or group design gave any signal that something was wrong.

That is the characteristic shape of an **architectural** mistake as distinct from
an **operational** one:

| | Operational error | Architectural error |
|---|---|---|
| When it surfaces | Immediately | At integration, or in production |
| Cost to fix | Minutes | Migration project |
| What it teaches | The tool | The system |

Recognizing the difference is worth more than a clean run would have been.
