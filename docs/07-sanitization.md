# 07 — Sanitization policy

A public security portfolio that leaks its own environment is the worst possible
own-goal. This document records what is redacted and why, so the redaction is
itself a demonstrated practice rather than an absence.

## Redacted throughout

| Item | Reason |
|---|---|
| Entra tenant ID (GUID) | No reader needs it; tenant IDs are enumerable enough without help |
| `.onmicrosoft.com` tenant domain | **Embeds a personal email address** |
| Administrator account email addresses | Personal contact information |
| Tailscale IP addresses (`100.x.x.x`) | Identifies a live host on a private mesh |
| Any password, hash, or key material | Obvious |
| `MSOL_` account full name | Contains the tenant-specific suffix |

## Retained deliberately

| Item | Reason |
|---|---|
| `peachpoint.local`, `PPT-DC01` | Fictional organization, lab hostname |
| `192.168.50.101` | RFC 1918 private space, no route from the internet |
| All personal names | Synthetic — the roster is fictional |
| OU and group names | Fictional org structure |

RFC 1918 addresses in an obvious home lab are not a meaningful disclosure, and
redacting them makes the documentation harder to follow for no security gain. The
line is drawn at anything that identifies a **real** person, account, or reachable
host.

## Per-screenshot redaction checklist

Before committing any image to `evidence/`, check it against this list. The
screenshot filenames are listed in [`../evidence/README.md`](../evidence/README.md).

| Screenshot | Must redact |
|---|---|
| `05-entra-admin-role.png` | Full UPN — leave `ppt-admin`, blur the tenant domain |
| `06-rdp-over-tailscale.png` | Tailscale IP in the RDP title bar |
| `08-ad-forest-account.png` | Nothing — username is fictional, password field is masked |
| `10-upn-suffix-warning.png` | Nothing — this is the whole point of the shot |
| `14-configuration-complete.png` | Nothing |
| `15-tenant-overview.png` | **Tenant ID and primary domain** — both visible |
| `16-synced-users.png` | UPN column — the domain suffix repeats on every row |
| `17-groups-breakdown.png` | Nothing — counts only |

### Redaction method

Use solid filled rectangles, not blur. Blur and pixelation are reversible on
short, low-entropy strings such as GUIDs and email addresses. A solid black or
white box is not.

Any Windows screenshot tool will do — Snip & Sketch, Paint, GIMP. Save the
redacted version as the committed filename and keep the original outside the repo
(`.gitignore` excludes `*-unredacted.*`).

> **Once a commit is pushed, redacting later does not help.** Git history retains
> the original. Redact before the first commit, or rewrite history and rotate
> anything exposed.
