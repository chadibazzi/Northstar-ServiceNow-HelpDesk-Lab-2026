# Case Study 04 — Shared Folder Access Denied: Active Directory, SMB, and NTFS

**Project:** Northstar Enterprise Help Desk Lab (ServiceNow)
**Case:** INC0010004  
**Type:** Controlled lab simulation with observed access failure and verified remediation  
**Date:** November 5, 2026 (UTC evidence)
**Final ServiceNow state:** Closed  
**Priority:** 4 — Low  
**Assignment group:** Northstar - Tier 1 Help Desk  
**Assigned technician (fictional lab persona):** Alex Morgan  
**Resolving ServiceNow account:** System Administrator

## Executive summary

An employee test account (`CORP\emily.carter`) received **Access Denied** when attempting to list an Accounting SMB share. Network connectivity to the file server on TCP 445 was working. Review of SMB share access, NTFS permissions, and AD group membership identified the missing entitlement: the employee was not a member of `GG_Northstar_Accounting_Access`. After adding the account to this purpose-built group and signing out/in to refresh the Windows security token, the employee could list the share, create a test file, and read it. The incident was documented, resolved, and closed in ServiceNow.

All systems and users in this report are part of an isolated training lab. This case is not a production incident.

## Environment

| Component | Lab value |
|---|---|
| Domain | `corp.local` |
| File server / domain controller | `DC01`, `10.0.0.50` |
| Client | `WIN11-CLIENT01`, `10.0.0.60` |
| Test user | `CORP\emily.carter` |
| Share | `\\10.0.0.50\Northstar-Accounting-Lab` |
| Folder | `C:\NorthstarLab\Accounting` |
| Authorized security group | `CORP\GG_Northstar_Accounting_Access` |
| Test file | `INC04-Test.txt` |

## Preflight and safe design

1. Verified the Windows Server service (`LanmanServer`) was running.
2. Confirmed an existing `Sales` share and `GG_Finance_Users` group, which were **not modified**.
3. Created a dedicated folder and group for the exercise.
4. Configured NTFS to allow `SYSTEM` and local Administrators full control and the dedicated Accounting group Modify. Configured SMB share permissions for Administrators Full and the dedicated Accounting group Change.
5. Did **not** grant `Everyone` or `Domain Users` broad access.

## Reproducing the symptom

From the Windows client, under the employee account:

```powershell
whoami
Test-NetConnection 10.0.0.50 -Port 445
Get-ChildItem "\\10.0.0.50\Northstar-Accounting-Lab" -ErrorAction Stop
```

**Observed:** `whoami` returned `corp\emily.carter`; TCP 445 connectivity succeeded; listing the share raised `UnauthorizedAccessException` / **Access is denied**. This distinguished network reachability from authorization failure.

## Diagnosis

AD membership checks showed the test account was initially in `Domain Users` but not in `GG_Northstar_Accounting_Access`. The share and NTFS permission model both depended on membership in the dedicated Accounting group. The absence of the entitlement explains the denial observed in this controlled case.

## Corrective action

Performed on DC01 by a lab administrator:

```powershell
Add-ADGroupMember -Identity "GG_Northstar_Accounting_Access" -Members "emily.carter"
Get-ADGroupMember "GG_Northstar_Accounting_Access" |
  Select-Object Name,SamAccountName
Get-SmbShareAccess -Name "Northstar-Accounting-Lab" |
  Select-Object AccountName,AccessRight,AccessControlType
```

After verifying membership and unchanged restricted share permissions, the test user signed out and signed back in to refresh the Windows authentication token.

## Post-remediation validation

```powershell
whoami
whoami /groups | findstr /i "Northstar"
Get-ChildItem "\\10.0.0.50\Northstar-Accounting-Lab" -ErrorAction Stop
"Northstar Accounting access verification - Incident 004" |
  Set-Content "\\10.0.0.50\Northstar-Accounting-Lab\INC04-Test.txt"
Get-Content "\\10.0.0.50\Northstar-Accounting-Lab\INC04-Test.txt"
Get-ChildItem "\\10.0.0.50\Northstar-Accounting-Lab" |
  Select-Object Name,Length,LastWriteTime
```

**Observed:** group membership appeared as enabled in the user's token, share directory access succeeded, `INC04-Test.txt` was created, its content read back correctly, and the directory listing showed the file. Final verification: **2026-11-05 19:29:43 UTC**.

## ServiceNow documentation and closure

- Logged the incident with **Network** category, **Phone** channel, and **Priority 4 - Low**.
- Recorded the pre-change denial, root cause, exact authorization fix, token refresh, and post-change file read/write evidence in internal work notes.
- Entered **Solution provided** and verified the incident changed from **In Progress → Resolved → Closed**.
- ServiceNow recorded the **System Administrator** account as resolver; **Alex Morgan** remained the assigned lab technician. These are not the same identity.
- The final screenshot displayed the resolution SLA as **Completed**, with **13 minutes** business elapsed and **0.46%** elapsed.

## Evidence index

All evidence filenames below refer to locally captured screenshots in `09_Screenshots`. Do not publish screenshots until they have been reviewed for identifiers, hidden windows, browser tabs, and other potentially sensitive details.

| ID | Filename | Evidence |
|---|---|---|
| 42 | `SNOW-42-INC04-Accounting-Lab-Resources.png` | Dedicated folder and AD group created |
| 43 | `SNOW-43-INC04-Accounting-NTFS-Permissions.png` | NTFS ACL and empty access group |
| 44 | `SNOW-44-INC04-Accounting-SMB-Share.png` | SMB share and restricted permissions |
| 45 | `SNOW-45-INC04-SMB-Access-Denied.png` | User, TCP 445 success, Access Denied |
| 46 | `SNOW-46-INC04-Accounting-Group-Membership.png` | AD membership added and share ACL verified |
| 47 | `SNOW-47-INC04-SMB-Access-Restored.png` | Group token, file creation/read, UTC verification |
| 48 | `SNOW-48-INC04-Shared-Folder-New-Incident.png` | New incident form |
| 49 | `SNOW-49-INC04-Shared-Folder-Incident-Submitted.png` | Saved incident |
| 50 | `SNOW-50-INC04-SMB-Troubleshooting-Work-Notes.png` | Root cause and remediation activity note |
| 51 | `SNOW-51-INC04-SMB-Resolution-Details.png` | Resolution fields prepared |
| 52 | `SNOW-52-INC04-SMB-Incident-Resolved.png` | Resolved state |
| 53 | `SNOW-53-INC04-SMB-Incident-Closed.png` | Closed state and completed SLA |

## Lessons learned

- A successful TCP 445 test does not establish permission to list an SMB share.
- Effective access is constrained by both **share** and **NTFS** permissions.
- Assigning access through a dedicated AD group is clearer and more maintainable than granting broad user access.
- Group changes can require a new sign-in session and refreshed network authentication before becoming effective.
- Verify the actual operation requested by the user (read, write, and list), not only group membership.
- Record before/after technical evidence and distinguish the assigned technician from the account that performed ServiceNow administrative actions.

## Follow-up / cleanup

The dedicated test share, file, and access group were intentionally retained for evidence and repeatable training. Before deleting anything, confirm no later lab uses these resources and export or retain the required screenshots. Any cleanup should target only the explicitly named lab artifacts.
