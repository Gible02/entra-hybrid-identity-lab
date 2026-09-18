# 01 — The business scenario

> **Peach Point Therapy is fictional.** It was designed to generate realistic
> constraints, not to represent any actual organization. All names are synthetic.

## The organization

Peach Point Therapy is a modeled outpatient physical and occupational therapy
practice operating **three clinic locations**:

| Site | Designation |
|---|---|
| North clinic | `North` |
| South clinic | `South` |
| West clinic | `West` |

## Staff — 21 people

| Role | Count | Access profile |
|---|---|---|
| Therapists (PT/OT) | 12 | Clinical records for assigned patients; scheduling |
| Administrative staff | 4 | Scheduling, correspondence, non-clinical records |
| Front desk | 3 | Check-in, appointments, demographics — not clinical notes |
| Billing | 1 | Claims and financial records; limited clinical for coding |
| Office manager | 1 | Operational oversight; de facto IT administrator |

## Constraints that drive the architecture

### 1. No full-time IT staff

The office manager is the de facto administrator. Anything requiring ongoing
attention — certificate renewals, federation server farms, a second synchronization
appliance to monitor — is a liability rather than a feature. **Maintenance burden
is a first-class design constraint here, not an afterthought.**

### 2. Staff float between sites

A therapist may cover North on Monday and West on Thursday. Identity has to follow
the person. This rules out site-local accounts and makes centralized identity
mandatory rather than merely convenient.

### 3. Regulated patient data

As a healthcare provider the practice operates under HIPAA. The *minimum necessary*
standard means access should be scoped to job function by default. Front desk and
billing should not have equivalent reach into clinical records. Retrofitting that
onto a flat directory is substantially worse than designing for it.

> **Scope note:** this lab demonstrates the *access-control principles* a regulated
> practice requires. It is not a HIPAA compliance implementation and makes no such
> claim. There is no BAA, no risk analysis, no audit control program.

### 4. Cloud-first application stack

Scheduling, EMR, and billing are SaaS. Staff authenticate to cloud services far
more often than to anything on-premises. The cloud identity is the one that gets
used.

### 5. A single domain controller

There is one DC. The practice cannot afford for cloud sign-in to stop when it does.
**This constraint alone determines the sign-in method** — see
[`04-design-decisions.md`](04-design-decisions.md).

## Problem statement

> Staff need one set of credentials that works across both the on-premises
> environment and the cloud application stack, managed centrally, without the
> practice taking on infrastructure it cannot maintain — and without cloud access
> depending on a single on-premises server staying online.

## Why this scenario rather than a generic one

A generic "sync AD to the cloud" lab produces no decisions. Every option looks
equivalent because nothing is at stake. This scenario was constructed so that the
constraints actually eliminate alternatives: constraint 5 rules out Pass-Through
Authentication and federation, constraint 1 rules out anything with a maintenance
tail, constraint 3 rules out a flat directory, and constraint 2 rules out
site-local identity.

The design is defensible because the constraints are specific.
