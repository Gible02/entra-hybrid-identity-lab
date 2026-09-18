# 04 — Design decisions

Each decision below had alternatives. The reasoning is what separates a lab that
was *followed* from a lab that was *designed*.

---

## 1. A separate forest, not a child domain of the existing lab

**Decision** — Built `peachpoint.local` as a brand-new forest, entirely separate
from the `lab.local` environment used for the ITSM project.

**Why** — The two environments model unrelated businesses. Joining them into one
forest would have been faster but would model something that does not happen: two
unaffiliated companies sharing a directory. Separation also forced the Entra
Connect configuration to stand on its own rather than inheriting existing trusts.

**Trade-off** — More infrastructure to maintain, and no opportunity to practice
cross-forest trusts. Accepted, because scenario fidelity mattered more than
convenience.

---

## 2. Site- and role-based OU structure

**Decision** — 12 OUs organized by both clinic location and job function, with 12
security groups mapped to roles.

**Why** — Two things had to be true simultaneously. Group Policy targets most
naturally by location, because printers, drive mappings, and local security
settings differ per clinic. Access control targets most naturally by role, because
HIPAA's minimum necessary standard means front desk and billing should not have
equivalent reach into patient records. Structuring for only one makes the other
painful.

**Trade-off** — A flatter structure would be simpler to administer, and for 21
people this is arguably over-engineered. But the structure is what makes delegated
administration and role-scoped access possible as the practice grows, and
retrofitting an OU design onto a live directory is meaningfully worse than
building it correctly up front.

---

## 3. Password Hash Synchronization over Pass-Through Authentication or AD FS

**Decision** — PHS, selected as the only optional feature.

**Why** — The single most consequential decision in the project, and constraint 5
settles it. With PHS, a hash of the on-premises password hash is synchronized to
Entra ID and **Entra authenticates users itself**. If `PPT-DC01` is offline —
hardware failure, patching, power loss at that site — staff still sign into the
cloud application stack they use all day.

Both alternatives fail that test:

| Method | Cloud sign-in survives DC outage? | Ongoing maintenance | On-prem footprint |
|---|---|---|---|
| **Password Hash Sync** | Yes | Minimal | Sync engine only |
| Pass-Through Authentication | No — auth validated on-premises | Agents to deploy, monitor, patch | Sync engine + agents |
| AD FS federation | No | Server farm, certificates, renewals | Farm + proxies + certs |

For a practice with no dedicated IT staff and one domain controller, PHS is not
the easy choice — it is the correct one. It is also a prerequisite for Entra ID
Protection's leaked-credential detection, a meaningful gain for an organization
that will never run a SOC.

**Trade-off** — PHS does not satisfy organizations with a hard policy against any
password-derived material leaving the premises. That objection is worth
understanding, but it does not apply to this profile, and the resilience gain
outweighs it.

---

## 4. Hybrid Identity Administrator, not Global Administrator

**Decision** — Created a dedicated cloud admin account and assigned **Hybrid
Identity Administrator** rather than Global Administrator.

**Why** — Least privilege applied to the administrator, not just to end users.
Hybrid Identity Administrator carries exactly the permissions Entra Connect needs
— directory synchronization, federation settings, seamless SSO — and nothing else.
Most walkthroughs reach for Global Administrator by reflex because it always
works. A scoped role means that if this account is compromised, the blast radius
is directory synchronization rather than the entire tenant.

**Trade-off** — Required verifying that the scoped role genuinely covered the full
setup rather than assuming it. It did.

---

## 5. A dedicated AD DS connector account, auto-created

**Decision** — Chose **Create new AD account**, supplying Enterprise Admin
credentials for the creation step only.

**Why** — Entra Connect generates a dedicated `MSOL_` account scoped precisely to
the directory read permissions the sync engine requires. The alternative —
designating an existing account — means the sync service runs with whatever
permissions that account carries, which in practice means a domain admin account
running as a service indefinitely.

**Trade-off** — Slightly less visibility into exactly what permissions were
granted. Mitigated by the account being documented, discoverable, and auditable
after the fact.

---

## 6. `mS-DS-ConsistencyGuid` as the source anchor

**Decision** — Selected **Let Azure manage the source anchor**.

**Why** — The source anchor is the immutable value linking each on-premises object
to its cloud counterpart. The legacy default, `ObjectGUID`, is genuinely immutable
— which becomes a liability, because it cannot be preserved if an object is ever
recreated or moved between forests. `mS-DS-ConsistencyGuid` is written back into
Active Directory, making the link portable. This turns forest migration and
disaster recovery from catastrophic into survivable.

**Trade-off** — Entra writes an attribute back into the on-premises directory.
That is a one-time attribute write, not a standing writeback channel, and the
recoverability it buys is worth far more.

---

## 7. Synchronizing the full directory rather than a pilot scope

**Decision** — Sync all domains, OUs, users, and devices.

**Why** — The complete 21-person roster is the artifact being demonstrated. Pilot
scoping exists so large organizations can validate sync against a handful of
accounts before committing — a real capability with no purpose at this scale.

**Trade-off** — In a production deployment, service accounts, disabled accounts,
and the Domain Controllers OU would be filtered before the first sync cycle.
Recorded as a deliberate lab simplification rather than an oversight.

---

## 8. Out-of-band administrative access via Tailscale

**Decision** — Administrative access to `PPT-DC01` over a Tailscale (WireGuard)
mesh rather than a port-forwarded RDP endpoint.

**Why** — RDP exposed to the internet is among the most reliably exploited entry
points in existence, and a domain controller is the worst possible host to expose
it on. A WireGuard mesh authenticates at the network layer before RDP is reachable
at all, with no inbound port open on the perimeter.

**Trade-off** — A dependency on a third-party coordination service, and one more
component that can be misconfigured. Worth it — a domain controller with RDP
facing the public internet is not defensible at any organization size.
