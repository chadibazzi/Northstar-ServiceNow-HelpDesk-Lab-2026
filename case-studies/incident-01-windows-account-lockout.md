# Incident 01 — Active Directory Account Lockout and Recovery

**Project:** ServiceNow Enterprise Help Desk Lab — 2026  
**Organization:** Northstar Technology Services *(fictional)*  
**ServiceNow incident:** `INC0010001`  
**Environment:** ServiceNow Zurich personal developer instance; isolated `CORP` Active Directory lab; Windows 11 test workstation  
**Status:** Resolved (verified in ServiceNow)  
**Classification:** Simulated help desk scenario supported by hands-on Windows/AD testing

> **Portfolio disclosure:** The employee, support organization, support technician, and ticket scenario are fictional. Authentication failures, directory status checks, Windows security events, account recovery, and successful interactive login were executed in a controlled lab. This is not a production incident or evidence of employment at Northstar.

## Scenario and business impact

An accounting employee reported being unable to sign in to a Windows workstation following unsuccessful password attempts. The first-line help desk was tasked with identifying the source of the lockout, restoring access, and documenting the work in ServiceNow.

**Ticket configuration**

| Field | Value |
|---|---|
| Caller | Emily Carter (fictional test user) |
| Assignment group | Northstar - Tier 1 Help Desk |
| Assigned to | Alex Morgan (fictional technician) |
| Category / subcategory | Software / Operating System |
| Channel | Phone (simulated contact channel) |
| Impact / urgency | 3 - Low / 2 - Medium |
| Calculated priority | 4 - Low |
| Final state | Resolved |
| Resolution code | Solution provided |

## Investigation and evidence

1. **Directory checks.** Confirmed the `ActiveDirectory` PowerShell module, `CORP` directory availability, and the default domain lockout settings: **3** failed attempts, **15-minute** lockout duration, and **15-minute** observation window.
2. **Account preparation.** Created a dedicated, nonprivileged `emily.carter` test user. The first account-creation attempt rejected the password, leaving the new directory object disabled. Corrected the password and enabled the account. Verified `Enabled=True`, `LockedOut=False`.
3. **Controlled reproduction.** Produced three invalid authentication attempts against only the dedicated lab account, after checking the lab environment. The domain controller reported `LockedOut=True`, `BadPwdCount=3`.
4. **Log analysis.** The domain controller's Windows Security log recorded **Event ID 4740**, naming **WIN11-CLIENT01** as the *Caller Computer Name* for `emily.carter`.
5. **Recovery.** Ran `Unlock-ADAccount -Identity "emily.carter"` from the domain controller. Subsequent directory checks showed `Enabled=True`, `LockedOut=False`, `BadPwdCount=0` at **2026-11-05 17:01:12 UTC**. **Event ID 4767** independently recorded the account unlock.
6. **User validation.** Successfully signed in to **WIN11-CLIENT01** as `corp\emily.carter`; `whoami` confirmed the logged-in identity at **2026-11-05 17:08:10 UTC**.
7. **Ticket resolution.** Posted initial triage and investigation notes in ServiceNow, selected **Solution provided**, and verified that incident `INC0010001` changed to **Resolved**.

### Selected PowerShell commands

```powershell
# Query account state
Get-ADUser -Identity 'emily.carter' -Properties Enabled,LockedOut,BadPwdCount,LastBadPasswordAttempt |
  Select-Object Name,SamAccountName,Enabled,LockedOut,BadPwdCount,LastBadPasswordAttempt

# Inspect recent account-lockout events on DC01
Get-WinEvent -FilterHashtable @{
  LogName='Security'; Id=4740; StartTime=(Get-Date).AddHours(-2)
} | Where-Object { $_.Message -match 'emily\.carter' } |
  Select-Object TimeCreated,Id,Message | Format-List

# Recovery action, performed only on the dedicated lab user
Unlock-ADAccount -Identity 'emily.carter'

# Confirm logged-on identity from Windows 11 client
whoami
(Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
```

## Root cause and corrective action

**Root cause of reproduced lockout:** Three deliberately invalid logon attempts for the dedicated test account from WIN11-CLIENT01 triggered the lab's configured domain account-lockout threshold. Event 4740 identifies the calling computer but does not by itself prove malicious activity. No evidence of a real-world attack is claimed.

**Corrective action:** Stopped the test, unlocked the account in Active Directory, verified directory recovery, and confirmed successful interactive workstation sign-in. The default domain-wide lockout policy was **not changed**.

## ServiceNow work performed

- Created and categorized incident `INC0010001` for the fictional caller.
- Assigned it to Northstar Tier 1 Help Desk / Alex Morgan.
- Recorded the initial triage approach and actual investigation findings as internal work notes.
- Tracked the incident through **In Progress → Resolved** with resolution code **Solution provided**.
- Kept the incident at **Resolved** rather than manually closing it without additional closure workflow.

## Evidence index

The original screenshots are stored locally in `09_Screenshots/`. Include only reviewed, sanitized copies in the public GitHub repository (for example, under `screenshots/incident-01/`).

| Local screenshot filename | Evidence |
|---|---|
| `SNOW-14-Windows-Account-Lockout-New-Incident.png` | New incident configuration before submission |
| `SNOW-15-Windows-Account-Lockout-Submitted.png` | Submitted incident and SLA |
| `SNOW-16-Account-Lockout-Initial-Triage.png` | Initial internal work note |
| `SNOW-17-AD-Account-Verification.png` | Enabled/unlocked AD test account with UTC timestamp |
| `SNOW-18-AD-Account-Lockout-Detected.png` | Locked account, three failed passwords, UTC timestamp |
| `SNOW-19-AD-Event4740-Lockout-Source.png` | Security Event 4740 naming the caller computer |
| `SNOW-20-AD-Account-Unlocked.png` | Verified unlock / Event 4767 |
| `SNOW-21-Emily-Successful-Login.png` | `whoami` proof on WIN11-CLIENT01 |
| `SNOW-22-Account-Lockout-Troubleshooting-Completed.png` | Detailed final investigation work note |
| `SNOW-23-Account-Lockout-Resolution-Details.png` | Completed resolution details |
| `SNOW-24-Account-Lockout-Resolved.png` | Incident state confirmed Resolved |

> **Security check before publishing:** Review each screenshot for live URLs, instance IDs, email addresses, full user/domain SIDs, internal IPs, credentials, tokens, and irrelevant user records. Redact as appropriate. Keep the unmodified originals locally; do not commit the originals to a public GitHub repo.

## Lessons learned

- ServiceNow record assignment, work notes, resolution codes, and activity history create an auditable support workflow.
- A password-policy rejection may leave a newly created directory object present but disabled; inspect state before attempting duplicate account creation.
- Security events 4740 and 4767 provide complementary lockout and unlock evidence.
- An account unlock alone is insufficient proof of restored productivity; verify successful user authentication.
- Distinguish simulated narrative from experimentally observed outcomes in portfolio documentation.

## Suggested next improvements

- Add a redacted incident-to-AD workflow diagram.
- Include a short technician-to-user communication template.
- Practice escalation to Tier 2 when the source computer remains unknown or the lockouts recur.
- Compare incident resolution and closure workflows, including SLA behavior.
