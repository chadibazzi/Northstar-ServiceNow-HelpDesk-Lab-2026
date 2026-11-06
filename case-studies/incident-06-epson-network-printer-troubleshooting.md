# Incident 006 — Epson Network Printer Troubleshooting

**Portfolio project:** ServiceNow Help Desk Lab (2026)  
**Incident:** INC0010006  
**Status:** Closed  
**Priority:** 4 — Low  
**Category:** Hardware  
**Caller:** Emily Carter (fictional lab identity)  
**Assignment group:** Northstar - Tier 1 Help Desk  
**Assigned technician:** Alex Morgan (fictional lab identity)  
**Resolved by in ServiceNow:** System Administrator (the logged-in account)  
**Date:** November 5, 2026

> **Lab disclosure:** This is a controlled training simulation, not a production incident. The printer was functioning before the test. Its **Windows 11 guest print queue** was intentionally paused to create a reproducible failure and then resumed. No real organizational outage is claimed.

## Executive summary

A physical **Epson ET-4800** network printer was connected to the **WIN11-CLIENT01** Windows 11 virtual machine in an Active Directory lab. A real Windows printer test page first confirmed end-to-end functionality. The guest's printer queue was then deliberately paused and verified with PowerShell, reproducing a common Tier 1 printing issue. Restoring the **Pause Printing** setting returned the queue to **Normal**, after which a second physical test page printed successfully. The incident was tracked through ServiceNow from New to In Progress to Resolved to Closed, with troubleshooting work notes, resolution notes, and completed SLA.

## Lab environment

| Component | Configuration |
|---|---|
| Guest workstation | WIN11-CLIENT01, Windows 11 x64, VirtualBox |
| Test user | `CORP\emily.carter` |
| Printer | Epson ET-4800 Series, physical Wi-Fi printer |
| Printer IPv4 | `10.0.0.90` (lab LAN) |
| Printer connection | WSD-discovered IPP printer |
| Driver | Microsoft IPP Class Driver |
| Print service | Windows Print Spooler, Running / Automatic |
| Service management | ServiceNow, incident `INC0010006` |
| Support workflow | Northstar Tier 1 Help Desk / Alex Morgan |

## Initial checks and baseline

1. Checked the Windows Print Spooler and confirmed it was **Running** with **Automatic** startup.
2. Confirmed the Epson printer's network configuration from its printed network status sheet: `10.0.0.90/24`, gateway `10.0.0.1`, IPP enabled.
3. From the virtual machine, verified TCP connectivity on the printer's IPP port **631** (`TcpTestSucceeded : True`). One `Test-Connection` operation reported a lookup error while other ping replies were received; TCP 631 provided the more relevant connectivity confirmation.
4. Installed the Epson in WIN11-CLIENT01 with the **Microsoft IPP Class Driver**; `Get-Printer` showed `PrinterStatus : Normal`.
5. Printed an actual Windows test page from `CORP\emily.carter` on WIN11-CLIENT01, confirming the initial working baseline.
6. Confirmed an empty printer queue: `PrinterStatus : Normal`, `JobCount : 0` at **2026-11-05 21:20:34 UTC**.

### Baseline PowerShell commands

```powershell
Get-Service Spooler | Select-Object Name,Status,StartType
Get-Printer | Select-Object Name,DriverName,PortName,PrinterStatus
Test-NetConnection 10.0.0.90 -Port 631
[DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss "UTC"')
Get-Printer -Name 'EPSON ET-4800 Series' |
    Select-Object Name,PrinterStatus,JobCount
Get-PrintJob -PrinterName 'EPSON ET-4800 Series' -ErrorAction SilentlyContinue |
    Select-Object ID,DocumentName,JobStatus
```

## Controlled failure reproduction

Because a real printer could be reached and printed successfully, the simulation was restricted to the **printer queue installed inside the Windows 11 VM**. The printer was not disabled on the host PC and no network or driver changes were performed.

- Opened the Epson queue using Windows printer UI:

  ```text
  rundll32 printui.dll,PrintUIEntry /o /n "EPSON ET-4800 Series"
  ```

- In the **Printer** menu, enabled **Pause Printing**.
- Verified the failure at **2026-11-05 21:24:11 UTC**:

  ```text
  Name                  PrinterStatus  JobCount
  EPSON ET-4800 Series  Paused         0
  ```

No print job was intentionally submitted while the queue was paused. Thus the measured failure was the **paused queue state**, not an observed stuck document.

## Diagnosis and corrective action

The observed fault was the paused state of the specific Windows printer queue; the network printer itself had previously printed correctly. This supports a **client-side queue configuration cause** for the controlled scenario rather than an IPP connectivity, printer hardware, or driver failure.

**Action:** Returned to the printer queue's **Printer** menu and unchecked **Pause Printing**. No spooler restart, driver reinstall, job deletion, or security-agent change was needed.

At **2026-11-05 21:30:17 UTC**, PowerShell confirmed:

```text
Name                  PrinterStatus  JobCount
EPSON ET-4800 Series  Normal         0
```

## Recovery validation

- Submitted a new Windows test page from WIN11-CLIENT01 under `CORP\emily.carter`.
- Observed `JobCount : 1` at **2026-11-05 21:31:54 UTC** while the test was processing. This was **not** independently evidence of a stuck job.
- Verified that the Epson produced a **second physical Windows Printer Test Page**, with submission time **4:31:33 PM on November 5, 2026**.
- The physical page demonstrated successful print output after restoring the queue.

**Result:** Printing was physically validated after the simulated issue was corrected.

## ServiceNow incident lifecycle

| Stage | Recorded outcome |
|---|---|
| New | Created with caller Emily Carter, category Hardware, impact Low, urgency Medium, calculated priority 4 — Low |
| In Progress | Assigned to Northstar - Tier 1 Help Desk / Alex Morgan; documented the reproduction and recovery |
| Work notes | Recorded service checks, network reachability, queue failure, corrective action, and test-page validation |
| Resolved | Resolution code **Solution provided**; ServiceNow set **Resolved by: System Administrator** |
| Closed | Final screenshot confirms **State: Closed** and SLA **Stage: Completed** |

### SLA result

| Measure | Verified value |
|---|---|
| SLA | Priority 4 resolution (2 day) |
| Target | Resolution |
| Final stage | Completed |
| Business elapsed time | 10 minutes (rounded ServiceNow display) |
| Business elapsed percentage | 0.36% |
| Stop time | 2026-11-05 13:40:11, as displayed by ServiceNow |

> ServiceNow's displayed timestamp is reproduced as shown; its display time zone was not independently verified. The SLA figures are **lab metrics**, not professional production performance claims.

## Evidence index

Store the following files in the project evidence folder, and link them appropriately when publishing. Filenames indicate expected evidence; references do not imply files are embedded in this Markdown report.

| No. | Evidence | Filename |
|---|---|---|
| 64 | Epson installed on Windows 11 VM with UTC timestamp | `SNOW-64-INC06-Epson-Printer-Installed.png` |
| 65 | Initial successful physical Windows test page | `SNOW-65-INC06-Epson-Physical-Test-Print.png` |
| 66 | Paused queue verification (`Paused`, 0 jobs) | `SNOW-66-INC06-Epson-Printer-Queue-Paused.png` |
| 67 | ServiceNow new incident form | `SNOW-67-INC06-Printer-New-Incident.png` |
| 68 | Submitted incident, assigned technician, and SLA | `SNOW-68-INC06-Printer-Incident-Submitted.png` |
| 69 | Printer returned from `Paused` to `Normal` | `SNOW-69-INC06-Epson-Printer-Queue-Restored.png` |
| 70 | Post-recovery physical test page | `SNOW-70-INC06-Epson-Post-Recovery-Test-Print.png` |
| 71 | Posted Tier 1 technical work notes | `SNOW-71-INC06-Printer-Troubleshooting-Work-Notes.png` |
| 72 | Completed ServiceNow resolution information | `SNOW-72-INC06-Printer-Resolution-Details.png` |
| 73 | Resolved incident with paused SLA | `SNOW-73-INC06-Printer-Incident-Resolved.png` |
| 74 | Closed incident with completed SLA | `SNOW-74-INC06-Printer-Incident-Closed-SLA.png` |

**Windows evidence directory:**

```text
C:\Users\bazzi\Desktop\ServiceNow_HelpDesk_Lab_2026\09_Screenshots\
```

**Suggested portfolio directory:**

```text
C:\Users\bazzi\Desktop\ServiceNow_HelpDesk_Lab_2026\11_Portfolio\
```

## Skills demonstrated

- Windows 11 network-printer discovery and configuration
- IPP (TCP 631), Wi-Fi printer connectivity checks, and WSD print queues
- PowerShell printer/service diagnostics (`Get-Service`, `Get-Printer`, `Get-PrintJob`, `Test-NetConnection`)
- Establishing an end-to-end working baseline before fault simulation
- Reversible, narrowly scoped printer-queue troubleshooting
- Physical post-remediation verification rather than relying only on status indicators
- ServiceNow incident creation, assignment, work notes, resolution, closure, and SLA reporting
- Clear separation between **simulated lab conditions** and production incidents

## Lessons learned

1. An installed printer showing **Normal** does not replace the need for an actual physical print test.
2. A paused local printer queue can prevent printing even when the printer and network are healthy.
3. `JobCount : 1` observed briefly while printing is not sufficient to conclude a job is stuck.
4. Prefer the smallest reversible corrective action. Do not restart the spooler or reinstall drivers without evidence that those changes are needed.
5. Differentiate the **assigned technician** from the **actual user recorded as resolving the incident** in ServiceNow.

---

**Outcome:** Controlled print-queue incident reproduced, corrected, physically validated, documented, and closed within the lab's SLA target.
