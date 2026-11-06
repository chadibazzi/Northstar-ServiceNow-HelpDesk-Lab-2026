# Incident 008 — OpenVPN Profile Missing / Tier 2 Escalation

**ServiceNow incident:** INC0010008  
**Project:** Northstar ServiceNow Help Desk Lab — 2026  
**Date of investigation:** November 6, 2026  
**Status at final verified screenshot:** On Hold — Awaiting Change; assigned to Tier 2 Infrastructure / Jordan Reed. No formal change request was verified.
**Scenario type:** Controlled training exercise; no verified production VPN outage.

## Executive summary

An employee using WIN11-CLIENT01 was unable to initiate a corporate VPN connection because the OpenVPN Connect client did not have an approved connection profile, server URL, or Cloud ID. Tier 1 checked installation and adapter presence, inspected available Windows VPN profiles and common `.ovpn` locations, and verified that the OpenVPN Connect application displayed its initial configuration screen. No working VPN endpoint was identified. The case was escalated to **Northstar - Tier 2 Infrastructure** for access approval and provisioning; it was **not** resolved as a restored VPN connection.

## Lab environment and ticket details

| Field | Value |
|---|---|
| Incident number | INC0010008 |
| Caller | Emily Carter (fictional lab user) |
| Windows account | `CORP\emily.carter` |
| Workstation | WIN11-CLIENT01 (Windows 11 Enterprise Evaluation VM) |
| VPN client | OpenVPN Connect 3.9.0 |
| Category | Software |
| Channel | Phone |
| Impact / urgency | 3 - Low / 2 - Medium |
| Calculated priority | 4 - Low |
| Original assignment | Northstar - Tier 1 Help Desk / Alex Morgan |
| Escalated assignment | Northstar - Tier 2 Infrastructure / Jordan Reed |
| Last verified state | In Progress |
| Confirmed resolution | None; VPN provisioning pending |

## Scope and known facts

- `OpenVPN Connect 3.9.0` was installed on WIN11-CLIENT01.
- TAP-Windows Adapter V9 for OpenVPN Connect and OpenVPN Data Channel Offload adapters were present and reported **Disconnected**. This is normal without an active tunnel.
- `Get-VpnConnection` returned no Windows-managed VPN profiles. OpenVPN Connect profiles do not necessarily appear in this cmdlet.
- No `.ovpn` files were found in Emily's Documents or Downloads folders in the checks performed. These checks do not exhaust every possible profile location.
- The OpenVPN Connect application displayed the initial connection setup screen, asking for a server URL or Cloud ID, or an `.ovpn` file.
- No authorized company VPN server endpoint or approved connection profile was identified for this workstation.
- No tunnel was established, and therefore no successful VPN connection or remote corporate resource access was demonstrated.

## Read-only troubleshooting commands

Executed from Windows PowerShell under `CORP\emily.carter`:

```powershell
[DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss "UTC"')
whoami
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
  Where-Object DisplayName -like '*OpenVPN*' |
  Select-Object DisplayName,DisplayVersion

Get-NetAdapter | Select-Object Name,InterfaceDescription,Status,LinkSpeed

Get-VpnConnection -ErrorAction SilentlyContinue |
  Select-Object Name,ServerAddress,ConnectionStatus

Get-ChildItem "$env:USERPROFILE\Documents","$env:USERPROFILE\Downloads" `
  -Filter '*.ovpn' -File -ErrorAction SilentlyContinue |
  Select-Object Name,DirectoryName
```

**Observed preflight timestamp:** `2026-11-06 15:15:55 UTC`.  
**Application-file check timestamp:** `2026-11-06 15:17:42 UTC`.

## Assessment and root cause

**Assessment:** The client cannot establish a connection because VPN provisioning information is missing or has not been supplied. This is a **missing configuration / access-provisioning scenario**, not evidence of a broken Windows VPN service or server outage. No network, DNS, or firewall changes were needed for Tier 1 diagnosis.

## Tier 1 actions and escalation

1. Verified OpenVPN client installation and virtual adapters.
2. Checked Windows-managed connection records and common profile file locations.
3. Inspected OpenVPN Connect GUI and captured its initial import/setup state.
4. Documented observations and limitations in ServiceNow work notes.
5. Reassigned incident from **Alex Morgan** / **Northstar - Tier 1 Help Desk** to **Jordan Reed** / **Northstar - Tier 2 Infrastructure**.
6. Posted a second work note identifying required Tier 2 actions.

### Requested Tier 2 actions

- Confirm whether VPN access is approved for the employee.
- Identify the sanctioned VPN service and server endpoint.
- Provide a trusted connection profile / URL or Cloud ID by approved means.
- Import the profile and validate authentication, tunnel establishment, and approved resource access.
- Update the ServiceNow ticket with actual results and a justified resolution state.

### ServiceNow workflow

The screenshot of the completed Tier 2 handoff shows **In Progress** with **Northstar - Tier 2 Infrastructure / Jordan Reed**, and Activity history includes a documented reassignment and escalation work note. The user subsequently requested an **On Hold** state, but that transition and its hold reason were **not yet verified** when this report was prepared. Update this section only after a saved screenshot confirms the actual state and reason.

**Do not record “VPN restored,” a successful connection test, or an SLA completed status** without new evidence.

## Evidence index

Store sanitized screenshots in `09_Screenshots/` and adjust the relative paths to match the repository structure.

| Screenshot | File | Evidence |
|---|---|---|
| 85 | `SNOW-85-INC08-OpenVPN-No-Connection-Profile.png` | OpenVPN Connect initial import screen with no connection profile shown |
| 86 | `SNOW-86-INC08-VPN-New-Incident.png` | Prepared ServiceNow incident form |
| 87 | `SNOW-87-INC08-VPN-Incident-Submitted.png` | Submitted ticket with In Progress state and Tier 1 assignment |
| 88 | `SNOW-88-INC08-VPN-Tier1-Troubleshooting-Work-Notes.png` | Posted Tier 1 investigation work note |
| 89 | `SNOW-89-INC08-VPN-Tier2-Escalation.png` | Reassignment to Jordan Reed and Tier 2 escalation work note |
| 90 (planned) | `SNOW-90-INC08-VPN-On-Hold-Tier2.png` | Hold status/reason, **only if actually saved and verified** |

## Additional lab work — separate from incident resolution

On KALI01, OpenVPN 2.7.3, OpenSSL 3.6.2, Easy-RSA 3.2.6-1, and `/dev/net/tun` were available. A separate `/home/kali/Northstar-VPN-Lab` workspace and PKI were initialized, and a lab CA certificate was generated. **No VPN server was configured or tunnel established.** These preparatory actions are unrelated to provisioning the fictional employee's authorized corporate VPN profile and should not be cited as a repaired incident.

The private CA key and passphrase are sensitive lab secrets and must not be committed to GitHub. Avoid committing the full `pki/private/` directory or unredacted VPN profiles.

## Skills demonstrated

- Windows VPN client and virtual-adapter inspection
- Differentiating client installation from VPN provisioning
- Limitations of Windows `Get-VpnConnection` for third-party VPN clients
- Accurate diagnosis without unsupported outage or recovery claims
- ServiceNow technical work notes, ownership transfer, and Tier 1-to-Tier 2 escalation
- Safe evidence handling and least-privilege troubleshooting

## Portfolio takeaway

This incident demonstrates a **correct support handoff** rather than a successful VPN repair. The technical outcome is a verified configuration gap, clear documentation, and reassignment to the infrastructure team for provisioning and connection validation.


## Final ServiceNow status update (November 6, 2026)

A later verified ServiceNow screenshot (`SNOW-90-INC08-VPN-On-Hold-Tier2.png`) shows the record in **On Hold**, reason **Awaiting Change**, assigned to **Northstar - Tier 2 Infrastructure / Jordan Reed**. This is the configured hold reason, not evidence of an approved change request. VPN provisioning and connectivity were **not** restored or verified.
