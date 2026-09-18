# 08 — Known gaps and next steps

Documented deliberately. An honest gap list is more useful than a tidy one, and
in an interview it is the difference between a project you built and a project you
understand.

## Time-sensitive

- [ ] **Upgrade Entra Connect Sync to version 2.5.79.0 or later.**
      Microsoft requires all installations to run this minimum version by
      **30 September 2026**; older builds stop synchronizing on that date due to a
      backend security hardening change. Check the installed version with
      `scripts/Get-SyncHealth.ps1`.

## Resilience

- [ ] **Enable the Active Directory Recycle Bin.** Flagged by the configuration
      wizard and not yet enabled. Without it, a deleted user or OU cannot be
      restored without a system state recovery. Run
      `scripts/Enable-RecycleBin.ps1`.
      **This is irreversible once enabled** — that is by design, not a warning
      against doing it.

- [ ] **Add a second domain controller.** A single DC is the largest structural
      weakness in the build. PHS means cloud sign-in survives its loss, but
      on-premises authentication, DNS, and Group Policy do not. A replica DC also
      unlocks demonstrable skills nothing else here covers: replication health via
      `repadmin /showrepl`, FSMO role placement and seizure, and an actual
      failover test.

- [ ] **Move Entra Connect off the domain controller.** Microsoft's guidance is a
      domain-joined member server. Installing on a DC works but would be a finding
      in a real assessment.

## Correctness

- [ ] **Audit the 12 synchronized groups** against the intended role-based design
      and confirm no unintended groups were carried across. Procedure in
      [`02-directory-design.md`](02-directory-design.md).

- [ ] **Remediate the UPN suffix.** Two production approaches in
      [`05-upn-suffix-problem.md`](05-upn-suffix-problem.md).

- [ ] **Filter service and disabled accounts** from the sync scope, as a
      production deployment would.

## Security posture

- [ ] **Enable Security Defaults or Conditional Access.** No multi-factor
      authentication is currently enforced, which is the single largest gap in the
      tenant's security posture. Security Defaults are available at no cost;
      Conditional Access requires Entra ID P1.

- [ ] **Review sign-in and audit logs.** Entra ID sign-in logs are the audit
      surface a regulated practice would rely on. Currently unexamined.

## Expansion

- [ ] **Device management.** The tenant shows zero devices. Hybrid Entra join and
      Intune enrollment are the logical next phase and extend this project into
      endpoint management.

- [ ] **Self-service password reset with writeback.** Requires Entra ID P1. Would
      meaningfully reduce help desk load in the modeled scenario — the most common
      ticket category in any organization.

- [ ] **Evaluate Entra Cloud Sync as the target state.** Microsoft now positions
      Cloud Sync as the preferred path for new deployments, and announced in April
      2026 that customers will ultimately migrate from Connect Sync to Cloud Sync
      — beginning with the smallest organizations, which is precisely this profile.
      A single-forest, 21-user practice with no PTA or federation requirement sits
      squarely within Cloud Sync's supported scenarios.

      Connect Sync was used here deliberately: it exposes the full configuration
      surface — sign-in method selection, source anchor choice, OU filtering,
      optional features — that Cloud Sync abstracts away. Learning the abstraction
      before the mechanism would have meant learning less. Migrating this
      environment to Cloud Sync is a worthwhile follow-on project in its own right.
