# Incident 007 — Notepad++ Installation Requires Administrator Approval

**Project:** ServiceNow Help Desk Lab Project — 2026  
**Organization:** Northstar (fictional training organization)  
**ServiceNow incident:** `INC0010007`  
**Date:** November 6, 2026  
**Classification:** Controlled Tier 1 Help Desk training simulation — not a production outage  
**Status:** **Closed** (verified in ServiceNow screenshot 84)  
**Category:** Software  
**Priority:** 4 — Low (Impact 3 — Low; Urgency 2 — Medium)  
**Caller:** Emily Carter (`CORP\emily.carter`)  
**Assignment group:** Northstar - Tier 1 Help Desk  
**Assigned technician:** Alex Morgan  
**Resolved by (ServiceNow audit field):** System Administrator

## 1. Executive summary

An employee working under a standard Windows account attempted to install Notepad++ on a domain-joined workstation. Windows User Account Control (UAC) requested administrator credentials, preventing the employee from continuing without authorization. The installer was verified for authenticity and integrity before an authorized lab administrator approved the installation. The application was then installed and launched successfully while the employee retained a standard-user security token.

**Outcome:** Authorized installation and functional validation succeeded. No permanent membership in the local Administrators group was granted, and no UAC or endpoint security controls were disabled.

> **Scope clarification:** This incident simulates an enterprise software-approval support request. The UAC prompt was **expected security behavior**, not a Windows Installer defect or a security-control failure. Approval was represented by the authorized administrator action in the lab; no separate formal corporate change-approval record was provided.

## 2. Lab environment

| Component | Verified detail |
|---|---|
| Workstation | `WIN11-CLIENT01` |
| Domain | `corp.local` |
| Employee account | `CORP\emily.carter` |
| Operating system | Windows 11 Enterprise Evaluation, 64-bit, version `10.0.26200` |
| Software | Notepad++ `8.9.8.1`, x64 |
| Installer | `npp.8.9.8.1.Installer.x64.exe` |
| Download source | Official Notepad++ downloads website |
| Windows Installer service (`msiserver`) | Stopped / Manual during preflight; normal on-demand service configuration |
| Application Information (`Appinfo`) | Running / Manual during preflight |
| ServiceNow | Personal Developer Instance, Northstar incident workflow |

The workstation also contained security monitoring software; those agents and their settings were not changed during this exercise.

## 3. User report and impact

**Reported request:** Emily Carter could not install Notepad++ on `WIN11-CLIENT01` without administrator authorization.

**Observed limitation:** The installer presented a UAC credential prompt asking for an administrator username and password. Installation did not proceed during the initial unapproved attempt.

**Impact:** One workstation's software-installation request was blocked pending administrative approval. There was no evidence of a broader system outage.

## 4. Investigation and evidence

### 4.1 Windows Installer and elevation prerequisites

The technician first inspected core installation components:

```powershell
Get-Service msiserver | Select-Object Name,Status,StartType
Get-Service msiserver,Appinfo | Select-Object Name,DisplayName,Status,StartType
```

Observed `msiserver = Stopped / Manual` and `Appinfo = Running / Manual`. A stopped on-demand Windows Installer service does **not** by itself establish an installation problem.

### 4.2 Employee permissions

Signed into the workstation as Emily Carter and checked the account's effective security token:

```powershell
[DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss "UTC"')
whoami
whoami /groups
```

Findings:

- Current user: `corp\emily.carter`.
- `BUILTIN\Users` present.
- Medium Mandatory Level security token.
- No Administrators membership shown in the current token.

A later verification repeated:

```powershell
whoami
whoami /groups | Select-String 'Administrators|Mandatory Level'
```

The check showed `Mandatory Label\Medium Mandatory Level`, and no Administrators match. This supports that the employee was not operating with an administrative token after installation.

### 4.3 Pre-installation application check

```powershell
Get-ItemProperty `
 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' `
 -ErrorAction SilentlyContinue |
Where-Object DisplayName -like '*Notepad++*' |
Select-Object DisplayName,DisplayVersion
```

No matching uninstall entry was found at baseline. This is evidence that Notepad++ was not registered in those uninstall locations; it is not proof that no portable copy existed anywhere on the system.

### 4.4 Installer integrity validation

Downloaded the x64 EXE from the official release page and verified the digital signature and SHA-256 digest before execution:

```powershell
Get-AuthenticodeSignature "$env:USERPROFILE\Downloads\npp.8.9.8.1.Installer.x64.exe" |
Select-Object Status,@{Name='Signer';Expression={$_.SignerCertificate.Subject}}

Get-FileHash "$env:USERPROFILE\Downloads\npp.8.9.8.1.Installer.x64.exe" -Algorithm SHA256
```

**Signature result:** `Valid`  
**Signer:** `NOTEPAD++`  
**Verified SHA-256:**

```text
26F3BCCED788FADBAC4E7E577B430EA2CE6060CF3BCAD993EF4612ECD7D743DA
```

The hash matched the expected published release digest used during the lab. Source: [Official Notepad++ download page for v8.9.8.1](https://notepad-plus-plus.org/downloads/v8.9.8.1/).

### 4.5 Reproduce the authorization requirement

From Emily's standard-user session, the installer was opened normally, **without** selecting *Run as administrator*.

Windows displayed a UAC prompt for **Notepad++**, with verified publisher `NOTEPAD++`, stating that an administrator username and password were required. No credentials were entered at that initial evidence step, and the installation attempt was canceled.

**Assessment:** Access was blocked pending administrative approval by design. No defect in Notepad++ or Windows Installer was demonstrated.

## 5. Corrective action

1. Confirmed the application's legitimacy and its need for administrator authorization.
2. Re-ran the already verified installer in Emily's session.
3. Entered authorized lab administrator credentials directly into the Windows UAC prompt.
4. Completed the standard Notepad++ installer wizard.
5. Did **not** modify Emily's group memberships, disable UAC, or stop endpoint security agents.

Credentials and passwords were not captured as evidence.

## 6. Recovery and validation

Verified the application installation in Windows uninstall-registry entries:

```powershell
[DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss "UTC"')
whoami
Get-ItemProperty `
 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' `
 -ErrorAction SilentlyContinue |
Where-Object DisplayName -like '*Notepad++*' |
Select-Object DisplayName,DisplayVersion,InstallLocation
```

**Observed:** `Notepad++ (64-bit x64)` version `8.9.8.1` under `corp\emily.carter`, at **2026-11-06 14:57:17 UTC**.

Then launched Notepad++ normally from the Start menu and opened **About Notepad++**, displaying `Notepad++ v8.9.8.1 (64-bit)`. This confirmed the application could run under the employee account.

Final user-token verification at **2026-11-06 14:59:35 UTC**:

```powershell
[DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss "UTC"')
whoami
whoami /groups | Select-String 'Administrators|Mandatory Level'
```

The token still reported `CORP\emily.carter` and Medium Mandatory Level, with no Administrators match. **No permanent user elevation was observed.**

## 7. ServiceNow incident workflow

| Stage | Verified record/evidence |
|---|---|
| New | `INC0010007` created, Category Software, Priority 4 — Low, assigned to Alex Morgan |
| In Progress | Ticket submitted, assignment and description retained; Priority 4 resolution SLA attached |
| Work notes | Investigation, signature/hash validation, UAC reproduction, administrative installation, and verification posted |
| Resolution | `Solution provided`; resolution notes entered |
| Resolved | State `Resolved`, resolution timestamp `2026-11-06 07:09:22` as displayed by ServiceNow; **Resolved by: System Administrator** |
| Closed | State `Closed` verified in screenshot 84 |

**SLA:** The Priority 4 resolution (2-day) SLA was visible in the submitted record. The final SLA row, business time consumed, final stage, and stop time were **not visible in screenshot 84**. Do not describe its final status as Completed or invent SLA performance metrics until a separate screenshot verifies them (planned screenshot 85).

> ServiceNow instance timestamps are shown exactly as displayed. The application/Windows screenshots use separately captured UTC times; the ServiceNow display timezone was not independently confirmed.

## 8. Screenshot evidence index

Evidence files are maintained in the local `09_Screenshots` folder. Screenshot filenames reflect the lab numbering scheme.

| # | Filename | Evidence |
|---|---|---|
| 75 | `SNOW-75-INC07-Software-Installation-UAC-Prompt.png` | Standard user prompted for administrative credentials |
| 76 | `SNOW-76-INC07-Software-Installation-New-Incident.png` | New ServiceNow incident form |
| 77 | `SNOW-77-INC07-Software-Installation-Submitted.png` | Saved In Progress ticket and SLA attachment |
| 78 | `SNOW-78-INC07-NotepadPlusPlus-Installation-Verified.png` | Installed application and version in registry |
| 79 | `SNOW-79-INC07-Standard-User-Verified.png` | Employee identity and Medium Mandatory Level |
| 80 | `SNOW-80-INC07-NotepadPlusPlus-Application-Validated.png` | Running application and About/version dialog |
| 81 | `SNOW-81-INC07-Software-Installation-Work-Notes.png` | Posted troubleshooting notes |
| 82 | `SNOW-82-INC07-Software-Installation-Resolution-Details.png` | Completed resolution fields before resolving |
| 83 | `SNOW-83-INC07-Software-Installation-Resolved.png` | Resolved state and audit attribution |
| 84 | `SNOW-84-INC07-Software-Installation-Closed-SLA.png` | Closed state (SLA details not visible) |
| 85 | `SNOW-85-INC07-Software-Installation-SLA-Completed.png` | **Pending / optional** — final SLA stage and metrics, if captured |

**Suggested GitHub screenshot layout:** Place sanitized copies in `assets/incident-07/` and update Markdown links to match the actual uploaded paths. Do not expose administrative credentials, tokens, private domain infrastructure details, or unnecessary personal information in a public repository.

## 9. Skills demonstrated

- Windows 11 software support and package installation troubleshooting.
- Standard-user versus administrator permissions, UAC, and least privilege.
- Windows PowerShell investigation and time-stamped evidence.
- Authenticode publisher signature and SHA-256 file integrity verification.
- Windows registry checks for application installation.
- Verifying the installed application's launch and version.
- ServiceNow incident routing, work notes, resolution notes, closure, and SLA awareness.
- Accurate distinction between **expected authorization controls** and a **software malfunction**.

## 10. Lessons learned

1. Verify the software's origin, signature, and hash before elevated installation.
2. A stopped `msiserver` service with Manual startup is not automatically an error.
3. Standard-user installation failures often reflect intended least-privilege enforcement.
4. Use an authorized administrator approval workflow rather than permanently granting local admin permissions.
5. Verify **both** installation registration and application launch before resolving the ticket.
6. Clearly attribute the ServiceNow resolving user and never infer SLA compliance from an incomplete screenshot.

---

**Portfolio result:** Controlled authorization scenario reproduced, software successfully installed and validated, the employee remained a standard user, and ServiceNow incident `INC0010007` was closed with documented troubleshooting and resolution.
