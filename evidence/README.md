# Evidence — screenshot manifest

**Drop your screenshots here using these exact filenames.** Every one is already
referenced from the README or a doc, so a correctly-named file renders
automatically with no editing.

Check each image against the redaction column before committing. Full policy:
[`../docs/07-sanitization.md`](../docs/07-sanitization.md).

---

## Have these already — from the Entra Connect build

| Filename | What it shows | Referenced in | Redact |
|---|---|---|---|
| `05-entra-admin-role.png` | Create user review screen — Hybrid Identity Administrator role assigned | `docs/03` | Tenant domain in the UPN |
| `06-rdp-over-tailscale.png` | RDP session to PPT-DC01, `whoami` returning `peachpoint\administrator` | `docs/03` | **Tailscale IP in title bar** |
| `07-connect-directories.png` | Connect your directories — forest `peachpoint.local` | `docs/03` | — |
| `08-ad-forest-account.png` | AD forest account prompt — empty credential fields, placeholder text only | `docs/03` | — |
| `09-directory-configured.png` | `peachpoint.local` configured, green check | `docs/03` | — |
| `10-upn-suffix-warning.png` | **Entra sign-in config — UPN suffix Not Added** | `README`, `docs/03`, `docs/05` | — |
| `11-ou-filtering.png` | Domain and OU filtering — sync all | `docs/03` | — |
| `12-identifying-users.png` | Uniquely identifying your users — source anchor managed by Azure | `docs/03` | — |
| `13-optional-features-phs.png` | **Optional features — password hash sync enabled** | `README`, `docs/03` | — |
| `14-configuration-complete.png` | Configuration complete, with the three post-config messages | `docs/03` | — |
| `15-tenant-overview.png` | Tenant overview — 24 users, 12 groups | `docs/06` | **Tenant ID and primary domain** |
| `16-synced-users.png` | All users list, 24 found | `README`, `docs/06` | UPN column suffix |
| `01-dc-promotion.png` | `Get-ADDomain` output | `docs/00` | Tailscale IP in RDP title bar |
| `02-ou-structure.png` | ADUC, full OU tree expanded | `docs/02` | Tailscale IP in RDP title bar |
| `04-user-roster.png` | Therapists OU — 12 real user accounts | `docs/02` | Tailscale IP in RDP title bar |
| `18-sync-scheduler.png` | `Get-ADSyncScheduler` output | optional | Tailscale IP in RDP title bar |
| `03-security-groups.png` | `Get-ADGroup` filtered to non-critical security groups — all 12 | `docs/02` | Tailscale IP in RDP title bar |
| `17-groups-breakdown.png` | Groups overview — 12 total, 12 on-premises, 0 cloud, 0 M365 | `README`, `docs/06` | Account chip (top right) |

The two in bold are the strongest images in the repo. `10` is the architectural
lesson; `13` is the decision that defines the build. `01`, `02`, `04`, `06`,
and `18` all had a live Tailscale IP (`100.x.x.x`) in the RDP window's title
bar — cropped off before committing, per policy.

---

Every planned screenshot in the manifest is captured, including both optional
bonus shots. `19-source-anchor-coverage.png` shows 21 users with a populated
source anchor (the full staff roster) against 4 without (the built-in/service
accounts — `Administrator`, `Guest`, `krbtgt`, and the `MSOL_` sync account —
which correctly stay unsynced individually). Nothing outstanding.

---

## Capture conventions

- **PNG, not JPEG.** Screenshots of text compress badly as JPEG.
- **Crop to the relevant window.** Full-desktop shots waste the reader's attention
  and are more likely to leak something in a taskbar or notification.
- **Width 1200px or greater** so text stays legible after GitHub scales it.
- **Redact with solid rectangles, never blur.** Blur is reversible on short,
  low-entropy strings like GUIDs and email addresses.
- Keep unredacted originals **outside the repo** — `.gitignore` excludes
  `*-unredacted.*` as a backstop, but the reliable approach is not putting them in
  the working tree at all.
