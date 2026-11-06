# Northstar — ServiceNow Help Desk & SOC Lab (2026)

**A hands-on, controlled IT support portfolio** demonstrating ServiceNow ITSM workflows, Windows 11 troubleshooting, Active Directory identity and access management, SMB permissions, endpoint telemetry, and escalation between Tier 1, Tier 2, and SOC teams.

> **Lab disclosure:** Northstar and its named staff/callers are fictional. The activities were performed in an isolated personal training environment. No production compromise, real company incident, employment relationship, or functioning Exchange/VPN provisioning is claimed. Some tickets remain On Hold because their underlying services were not restored or telemetry was not fully verified.

## Project at a glance

- **10 scenarios documented**: 9 ServiceNow incidents and 1 standalone catalog task.
- **Platform**: ServiceNow Zurich Personal Developer Instance (PDI).
- **Infrastructure**: VirtualBox VMs with an isolated Windows Active Directory domain (`corp.local`), Windows 11 client, and Wazuh/Sysmon monitoring components.
- **Workflow**: triage → reproduce or diagnose → verify evidence → document notes → resolve/close **or** escalate and leave pending when not fixed.
- **Evidence**: 115-numbered lab screenshot sequence maintained locally; sanitized public evidence is optional and is **not bundled** here.

## Case studies

| # | Scenario | ServiceNow record | Verified / documented outcome |
|---|---|---|---|
| 01 | [AD Account Lockout](case-studies/incident-01-windows-account-lockout.md) | `INC0010001` | Closed / recovered |
| 02 | [Outlook / Exchange Mailbox](case-studies/incident-02-outlook-mailbox-investigation.md) | `INC0010002` | On Hold / escalated |
| 03 | [DNS Resolution Simulation](case-studies/incident-03-dns-resolution-failure.md) | `INC0010003` | Closed / simulated |
| 04 | [SMB Access Denied](case-studies/incident-04-smb-access-denied.md) | `INC0010004` | Closed / access restored |
| 05 | [Workstation CPU Performance](case-studies/incident-05-windows-performance-troubleshooting.md) | `INC0010005` | Closed / recovered |
| 06 | [Epson Printer Queue Paused](case-studies/incident-06-epson-network-printer-troubleshooting.md) | `INC0010006` | Closed / printing verified |
| 07 | [Software Installation / UAC](case-studies/incident-07-notepadpp-installation-authorization.md) | `INC0010007` | Closed / installed |
| 08 | [VPN Profile Missing](case-studies/incident-08-openvpn-missing-profile-tier2-escalation.md) | `INC0010008` | On Hold / Tier 2 |
| 09 | [New Hire AD Onboarding](case-studies/incident-09-active-directory-new-hire-onboarding.md) | `SCTASK0010001` | Closed Complete / standalone task |
| 10 | [PowerShell / SOC Escalation](case-studies/incident-10-powershell-sysmon-soc-escalation.md) | `INC0010009` | On Hold / SOC |

## Skills demonstrated

ServiceNow incident management, priority and assignment, resolution notes, work notes, SLAs, catalog tasks, Windows authentication, AD provisioning and password-policy handling, least-privilege group access, SMB/NTFS ACL analysis, PowerShell diagnostics, application installation and UAC, network and printer troubleshooting, Wazuh/Sysmon verification, and handoff documentation.

## Architecture

See [architecture diagram](docs/architecture.md) and [verification matrix](docs/evidence-manifest.md).

## What the portfolio does **not** claim

- Case 02 did **not** restore a working Exchange Online mailbox; licensing/mailbox prerequisites were missing.
- Case 03 intentionally simulated a single failed DNS query rather than a machine-wide outage.
- Case 08 did **not** establish a real VPN connection or approved change request.
- Case 09 is a **standalone ServiceNow catalog task**, not an approved RITM with completed email/hardware provisioning.
- Case 10 used an **authorized harmless** PowerShell test; it did not show a breach or prove Wazuh received the matching event.

## Repository layout

```text
.
├── README.md
├── case-studies/           # Ten individually documented cases
├── docs/
│   ├── architecture.md     # Mermaid architecture drawing
│   ├── evidence-manifest.md
│   └── publishing-checklist.md
├── evidence/reviewed/      # Intentionally empty: only manually reviewed sanitized screenshots
└── scripts/
    └── collect-evidence.ps1
```

## Publishing evidence

Screenshots collected on the user's PC may show hostnames, internal IP addresses, accounts, browser details, or sensitive administrative information. **Do not upload the original screenshot folder unreviewed.** Follow [publishing checklist](docs/publishing-checklist.md). Use the optional [PowerShell evidence helper](scripts/collect-evidence.ps1) to copy selected originals into a private staging folder; inspect and redact them before placing public copies under `evidence/reviewed/`.

## Reproduction and safety

Use only personally controlled isolated lab systems and test identities; preserve baseline snapshots and back up configuration before changes. Avoid disabling security protections. Account/password examples and event markers are training-only.

## Repository owner

Prepared for GitHub account **[@chadibazzi](https://github.com/chadibazzi)**. Repository publishing and GitHub ownership have not yet been verified.**Repository owner:** [@chadibazzi](https://github.com/chadibazzi)

This project is published as a personal, hands-on ServiceNow Help Desk and SOC training portfolio. All company names, users, and incidents are fictional lab scenarios.
