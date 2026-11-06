# Case Study 09 — New Employee Active Directory Onboarding

**Northstar Help Desk Lab | 2026**  
**ServiceNow record:** `SCTASK0010001` (standalone catalog task, **Closed Complete**)  
**Employee:** Olivia Bennett (fictional) | **AD username:** `CORP\olivia.bennett`  
**Assigned technician:** Alex Morgan (fictional) | **Environment:** `corp.local`, DC01, WIN11-CLIENT01

## Executive Summary

Provisioned a fictional Sales employee in an on-premises Active Directory training lab. An initial attempt to create the account encountered a domain password-policy rejection; the account existed afterward but was disabled. After reviewing the domain policy, a compliant temporary password was set, the account was enabled, and password change at first logon was required. The user was granted membership in the existing Sales security group. Successful workstation authentication, effective group membership, and **read** access to an existing Sales SMB share were verified. Work was documented in ServiceNow and the standalone catalog task was closed complete.

**Scope limitation:** This is a controlled lab case, not a production employee onboarding. Exchange email, Microsoft 365 licensing, dedicated hardware, and VPN access were **not** provisioned. The catalog task had no associated RITM; its Requested for reference was blank after submission despite having been selected on the new-record form. No formal approval workflow is claimed.

## Environment and Controls

| Component | Value |
|---|---|
| Domain / NetBIOS | `corp.local` / `CORP` |
| Domain functional level | `Windows2025Domain` |
| Domain controller | DC01 (`10.0.0.50`) |
| Employee OU | `OU=Corp Users,DC=corp,DC=local` |
| Access group | `GG_Sales_Users` |
| Workstation | WIN11-CLIENT01 |
| Sales SMB path | `\\10.0.0.50\Sales` |
| Sales share backing directory | `C:\CompanyShares\Sales` |
| ServiceNow task | `SCTASK0010001`, Priority 4 - Low, assigned Alex Morgan |

## Investigation and Work Performed

### 1. Confirm prerequisites

- Identified the Corp Users and Corp Groups OUs.
- Verified `olivia.bennett` did not already exist prior to creation.
- Inspected `GG_Sales_Users`, a Global group initially containing two users: John Employee and Alex Newhire.

### 2. Create account and handle policy failure

A `New-ADUser` operation specified Olivia Bennett, Sales department, Sales Coordinator title, and `ChangePasswordAtLogon`. The first temporary password failed AD password-policy validation (`ADPasswordComplexityException`, error 1325). Follow-up lookup found the account with `Enabled = False` and `PasswordExpired = True`.

The default domain password policy showed:

| Policy | Observed value |
|---|---|
| Minimum password length | 7 |
| Password complexity | Enabled |
| Password history | 24 |
| Maximum password age | 42 days |

The technician reset the temporary password using `Read-Host -AsSecureString` and `Set-ADAccountPassword -Reset`, enabled the user, and required password change at next sign-in. At **2026-11-06 16:25:33 UTC**, AD returned `Enabled = True`, department Sales, title Sales Coordinator, and `PasswordExpired = True` (consistent with first-logon change required). No passwords were recorded in evidence.

### 3. Assign least-privilege group membership

Added `olivia.bennett` to `GG_Sales_Users` using `Add-ADGroupMember`. A membership query at **2026-11-06 16:37:30 UTC** listed only `Domain Users` and `GG_Sales_Users` among the returned groups; no administrative role was assigned.

### 4. Validate workstation login

Signed in to WIN11-CLIENT01 as `CORP\olivia.bennett`. At **2026-11-06 16:52:00 UTC**, `whoami` confirmed Olivia's account; `whoami /groups` showed `CORP\GG_Sales_Users` enabled and **Medium Mandatory Level**. This verifies domain login and effective Sales membership, not access to every possible Sales resource.

### 5. Validate Sales share access

DC01 showed an SMB share named `Sales` at `C:\CompanyShares\Sales`. `Get-SmbShareAccess` showed `CORP\GG_Sales_Users` with **Allow — Change** at the share layer. NTFS (`icacls`) showed the Sales group with **Read & Execute (RX)**, plus inherited permissions for `BUILTIN\Users` (including folder creation-related entries). The access model was not exclusive to the Sales group.

From Olivia's session, `Get-ChildItem "\\10.0.0.50\Sales"` listed two existing files without error, and `Test-Path` returned `True` at **2026-11-06 16:54:15 UTC**. **Only read/list access was directly demonstrated**; write access and exclusivity were not established.

### 6. Record work in ServiceNow

- Reviewed the New Hire order guide; it bundled laptop, monitor, Exchange email, VPN, and desk setup requests outside the tested scope. It was **not** checked out.
- A catalog search for `user account` returned group-cloning and VPN items rather than a suitable dedicated user-provisioning catalog item.
- Created a separate ServiceNow user record for Olivia (`northstar.employee02`) for the reference lookup; this is not evidence of AD synchronization or a working email mailbox.
- Created standalone catalog task `SCTASK0010001`, assigned Alex Morgan, priority 4, with completed onboarding details and internal work notes.
- After submission, **Requested for was blank** and **Request item (RITM) was blank**. The task was used explicitly as a training documentation record, without a verified request/approval chain.
- Final screenshot confirmed task state **Closed Complete**, Active unchecked, and three Activity entries.

## Evidence Index

Evidence files are stored in the project's `09_Screenshots` folder. The screenshots listed below were captured or reviewed during the workflow; filename capitalization should be preserved when linking them in a public repository.

| Screenshot | Evidence description |
|---|---|
| `SNOW-91-INC09-AD-Initial-Password-Policy-Failure.png` | Initial disabled AD account and password-policy findings |
| `SNOW-92-INC09-AD-Password-Policy-Corrected.png` | Corrected password, account enabled |
| `SNOW-93-INC09-AD-Sales-Group-Membership.png` | Domain Users and Sales group |
| `SNOW-94-INC09-New-Employee-Domain-Login.png` | Olivia's Windows login token and Sales group |
| `SNOW-95-INC09-Sales-Share-Access-Verified.png` | Successful Sales share listing and `Test-Path` |
| `SNOW-96-INC09-ServiceNow-New-Hire-Catalog-Found.png` | New Hire catalog discovery |
| `SNOW-97-INC09-New-Hire-Request-Form.png` | Order guide needs form |
| `SNOW-98-INC09-New-Hire-Order-Options.png` | Bundled provisioning options |
| `SNOW-99-INC09-New-Hire-Email-Account-Options.png` | Exchange account item outside lab scope |
| `SNOW-100-INC09-ServiceNow-Account-Request-Search.png` | Catalog user-account search |
| `SNOW-101-INC09-Catalog-Task-Options.png` | Blank task creation form |
| `SNOW-102-INC09-ServiceNow-New-Employee-User-Form.png` | ServiceNow user record preparation |
| `SNOW-103-INC09-Catalog-Task-Olivia-Selected.png` | Requested-for lookup selected during draft |
| `SNOW-104-INC09-AD-Onboarding-Catalog-Task-Completed-Form.png` | Task description before submission |
| `SNOW-105-INC09-AD-Onboarding-Task-Submitted.png` | Persisted task and missing references |
| `SNOW-106-INC09-AD-Onboarding-Completion-Work-Notes.png` | Internal completion notes |
| `SNOW-107-INC09-AD-Onboarding-Catalog-Task-Closed.png` | Closed Complete task and activity history |

**Portfolio sanitation checklist:** Review screenshots for passwords, tokens, personal identifiers, server addresses not meant for publication, and other private data. This case uses a fictional employee and an isolated lab domain.

## Outcome and Skills Demonstrated

**Completed:** AD user provisioning, password-policy diagnosis and correction, secure temporary password handling, domain sign-in, Sales group membership, SMB share read-access verification, ServiceNow task documentation, and closure.

**Not claimed:** Domain-to-ServiceNow synchronization, formal hiring-manager approval, Exchange mailbox creation, hardware issuance, VPN provisioning, or end-to-end service-request fulfillment through an approved RITM.

**Skills:** Active Directory, Group Policy/password-policy troubleshooting, PowerShell, Windows identity, group-based access, SMB vs NTFS authorization, ServiceNow catalog task workflow, evidence preservation, and honest scope reporting.
