# Case Study 03 — DNS Resolution Failure (Controlled Simulation)

**Project:** ServiceNow Enterprise Help Desk Lab — 2026  
**Organization:** Northstar Technology Services (fictional)  
**ServiceNow incident:** INC0010003  
**Category:** Network / DNS  
**Caller:** Emily Carter (fictional)  
**Assigned to:** Alex Morgan, Northstar - Tier 1 Help Desk (fictional)  
**Final ticket state:** Closed  
**Priority:** 4 - Low

## Executive summary

This training case demonstrates the process of investigating a DNS resolution failure on a domain-joined Windows lab workstation. A query was deliberately directed to an unavailable test DNS endpoint, `127.0.0.2`, producing Win32 error `10054`. Normal internal and external DNS resolution were subsequently verified without changing the workstation's adapter settings. **The simulated query failure was real; no workstation-wide or production DNS outage occurred, and no infrastructure repair was needed.**

## Lab environment and prerequisites

- Windows client: `WIN11-CLIENT01`, Windows 11 Enterprise Evaluation.
- AD DNS environment: `corp.local`, internal DNS address `10.0.0.50`.
- DNS adapters observed: `Ethernet` using `10.0.0.50`, and `Ethernet 2` using `75.75.75.75` and `75.75.76.76`.
- ServiceNow personal developer instance: fictitious Northstar team, caller, ticket and assignment.
- DNS query tests: `Resolve-DnsName` and `Test-NetConnection`.

## Investigation procedure and evidence

### 1. Establish a healthy baseline

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4 |
  Where-Object { $_.ServerAddresses.Count -gt 0 } |
  Select-Object InterfaceAlias,ServerAddresses

Resolve-DnsName dc01.corp.local -Type A |
  Select-Object Name,IPAddress

Resolve-DnsName www.microsoft.com -Type A |
  Select-Object Name,IPAddress

Test-NetConnection 10.0.0.50 -Port 53
```

**Observed:** Internal and public names resolved. The domain controller name returned IPv4 addresses `10.0.0.50`, `10.0.4.15`, and `192.168.56.101`. TCP connectivity to port 53 on `10.0.0.50` succeeded. A successful TCP 53 test does not alone prove UDP DNS availability.

**Evidence:** `SNOW-34-INC03-DNS-Baseline-Verification.png` (UTC timestamp 2026-11-05 18:37:42).

### 2. Reproduce the isolated lookup failure

```powershell
Resolve-DnsName www.microsoft.com -Server 127.0.0.2 -DnsOnly -ErrorAction Continue
(Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
```

**Observed:** Query failed with *An existing connection was forcibly closed by the remote host*, Win32 exception `10054`. The command explicitly selected `127.0.0.2` and did not modify the system DNS configuration.

**Evidence:** `SNOW-35-INC03-DNS-Failure-Simulation.png` (UTC timestamp 2026-11-05 18:39:09).

### 3. Verify normal lookup still works

```powershell
Resolve-DnsName www.microsoft.com -Type A |
  Select-Object Name,IPAddress
```

**Observed:** The default resolver successfully returned an answer through the Microsoft CDN CNAME chain, with IPv4 address `23.222.22.103` during the test. CDN answers can vary across locations and times.

## Diagnosis and resolution

The command-specific failure was caused by directing a DNS lookup to an unavailable test endpoint, not by a failure of the workstation's configured DNS services. No adapter settings were changed; there was nothing to roll back. The training objective was satisfied by reproducing the failure and proving that normally configured lookups continued to work.

**ServiceNow resolution code:** Solution provided (for the completed training exercise only).  
**Resolved by shown in ServiceNow:** System Administrator, while the ticket was assigned to Alex Morgan.  
**SLA:** Completed, 7 minutes of business elapsed time (0.26% shown in final screenshot).  
**Final ticket:** Closed.

**Evidence of ticket workflow:**

| Screenshot | Content |
|---|---|
| `SNOW-36-INC03-DNS-New-Incident.png` | Incident creation form |
| `SNOW-37-INC03-DNS-Incident-Submitted.png` | Submitted incident, Tier 1 assignment, priority and SLA |
| `SNOW-38-INC03-DNS-Investigation-Work-Notes.png` | DNS investigation documented in activity history |
| `SNOW-39-INC03-DNS-Resolution-Details.png` | Resolution fields before saving |
| `SNOW-40-INC03-DNS-Resolved.png` | Resolved ticket and SLA stage |
| `SNOW-41-INC03-DNS-Closed.png` | Closed ticket and completed SLA |

## Production troubleshooting runbook

1. Confirm scope: one application, one workstation, or a network-wide issue; record the exact hostname and error.
2. Compare hostname resolution with IP reachability; verify current DNS adapter settings and search suffix.
3. Query the configured resolver directly and, when authorized, compare with a known-working resolver.
4. Investigate server availability, routing, UDP/TCP 53 reachability, DNS records, cache, VPN/split-DNS, and multiple NIC registrations as indicated by evidence.
5. Correct only the identified configuration or service fault under change-control policy.
6. Validate internal and public name resolution and the original application workflow, then document user confirmation and closure.

## Lessons learned

- A failed query against a deliberately unavailable DNS server is not evidence of a production-wide DNS outage.
- DNS answer records can show multiple IP addresses on multi-homed domain controllers; investigate their appropriateness separately before changing them.
- Distinguish name resolution, TCP connectivity, and application reachability.
- Keep incident work notes, UTC timestamps, and observed output distinct from fictional user reports and training simulations.

## Publishing and privacy

Before sharing screenshots on GitHub, make sanitized copies that conceal browser profiles, account identifiers, tenant IDs, tokens, passwords, personal data and unrelated applications/tabs. Preserve originals locally. Use relative screenshot paths in the repository, and describe the case as a **controlled lab simulation**, not a repaired live outage.
