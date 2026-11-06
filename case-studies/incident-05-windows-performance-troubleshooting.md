# Incident 005 — Windows Workstation Performance Troubleshooting

**Project:** Northstar ServiceNow Enterprise Help Desk Lab 2026  
**Case type:** Controlled training simulation — not a production outage  
**ServiceNow incident:** `INC0010005`  
**Date:** November 5, 2026 (UTC evidence timestamps)  
**Environment:** Windows 11 Enterprise Evaluation, `WIN11-CLIENT01` (VirtualBox), domain `corp.local`  
**Simulated caller:** Emily Carter  
**Assigned technician:** Alex Morgan  
**Assignment group:** Northstar - Tier 1 Help Desk  
**Category/Subcategory:** Hardware / CPU  
**Channel:** Phone  
**Impact/Urgency/Priority:** 3 - Low / 2 - Medium / 4 - Low  
**Reported final status:** Closed (user confirmed after capturing final screenshot; last screenshot inspected by assistant showed Resolved)

## Executive summary

This case demonstrates a Tier 1 service desk workflow for investigating reported workstation slowness. On an isolated Windows 11 lab VM, a deliberately time-limited PowerShell job increased CPU utilization. The technician collected system baselines, monitored resource usage and process activity, confirmed the test job completed, and validated CPU utilization returned to normal. The scenario was documented in ServiceNow with investigation work notes and resolution notes.

**Scope statement:** Elevated CPU utilization was deliberately generated for training. No verified user-visible slowdown, malicious activity, production outage, or actual device fault was established.

## ServiceNow ticket lifecycle

1. Created incident `INC0010005` with caller Emily Carter, assigned to Alex Morgan in Northstar - Tier 1 Help Desk.
2. Submitted incident; ServiceNow displayed **In Progress** and a Priority 4 resolution SLA with a two-day target.
3. Posted technical work notes documenting baseline, controlled workload, investigative checks, and final recovery verification.
4. Entered resolution code **Solution provided**, with notes accurately identifying the test as a simulation.
5. Resolved incident. The verified screenshot showed **Resolved by: System Administrator**, reflecting the ServiceNow account that executed the action, rather than the assigned technician.
6. User subsequently confirmed closing the incident; inspect the final captured `SNOW-63` screenshot for the definitive Closed state and SLA completion before publishing.

## Lab and preflight verification

- Four logical processors; approximately 8 GB physical RAM.
- C: volume: 78.9 GB total, 34.1 GB free.
- Baseline CPU utilization across three samples: **15.6%, 13.8%, 11.7%**; mean **13.7%**.
- Observed security-related processes included Microsoft Defender (`MsMpEng`) and Elastic collectors. These were not disabled, stopped, or uninstalled.

### Commands — baseline

```powershell
Get-CimInstance Win32_OperatingSystem |
  Select-Object CSName,TotalVisibleMemorySize,FreePhysicalMemory

Get-CimInstance Win32_ComputerSystem |
  Select-Object Name,NumberOfLogicalProcessors,TotalPhysicalMemory

Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' |
  Select-Object DeviceID,
    @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,1)}},
    @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,1)}}

Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 2 -MaxSamples 3 |
  Select-Object -ExpandProperty CounterSamples |
  Select-Object @{Name='CPUPercent';Expression={[math]::Round($_.CookedValue,1)}}
```

## Controlled fault reproduction

A temporary PowerShell background job performed CPU-bound mathematics for approximately 20 seconds. No persistent configuration or service changes were made.

```powershell
$job = Start-Job -ScriptBlock {
    $end = [DateTime]::UtcNow.AddSeconds(20)
    while ([DateTime]::UtcNow -lt $end) {
        for ($i = 0; $i -lt 100000; $i++) {
            $null = [Math]::Sqrt($i)
        }
    }
}
$job | Select-Object Id,Name,State
```

### CPU measurement during load

```powershell
Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 2 -MaxSamples 5 |
  Select-Object -ExpandProperty CounterSamples |
  Select-Object @{Name='CPUPercent';Expression={[math]::Round($_.CookedValue,1)}}

$job | Select-Object Id,State,HasMoreData
```

Observed samples: **51.5%, 50.8%, 46.6%, 45.2%, 44.8%**.  
Average: **47.8%**; peak: **51.5%**.  
The job transitioned from `Running` to `Completed` (`HasMoreData: False`).  
Evidence time: **2026-11-05 20:23:29 UTC**.

## Investigation after the workload ended

The first post-job sample series remained elevated at **39.5%, 48.2%, 51.5%, 40.8%, and 43.0%**, averaging **44.6%** (evidence time **20:26:05 UTC**). This required additional measurement, not a premature assertion that recovery had occurred.

Additional read-only process investigation:

```powershell
Get-Process |
  Sort-Object CPU -Descending |
  Select-Object -First 12 ProcessName,Id,
    @{Name='TotalCPUSeconds';Expression={[math]::Round($_.CPU,1)}}

Get-Counter '\Process(*)\% Processor Time' -SampleInterval 2 -MaxSamples 2 |
  Select-Object -ExpandProperty CounterSamples |
  Where-Object { $_.InstanceName -notmatch '^(_total|idle)$' -and $_.CookedValue -gt 0 } |
  Sort-Object CookedValue -Descending |
  Select-Object -First 15 InstanceName,
    @{Name='CPUPercentRaw';Expression={[math]::Round($_.CookedValue,1)}}

Get-CimInstance Win32_Processor |
  Select-Object Name,LoadPercentage
```

Windows Terminal had the highest observed recent per-process CPU activity; this **did not establish causation** for the earlier elevated overall CPU. A subsequent processor load reading was **19%** at **2026-11-05 20:27:47 UTC**. No monitoring agents or system processes were terminated.

## Recovery verification

The final five samples were **0%, 0.8%, 0%, 3.6%, and 2.4%**, averaging **1.36%**, with the temporary background job still shown as **Completed**.

```powershell
Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 2 -MaxSamples 5 |
  Select-Object -ExpandProperty CounterSamples |
  Select-Object @{Name='CPUPercent';Expression={[math]::Round($_.CookedValue,1)}}

Get-Job | Select-Object Id,Name,State
(Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
```

Final verification time: **2026-11-05 20:30:09 UTC**.

| Phase | Average CPU |
|---|---:|
| Pre-test baseline | 13.7% |
| During controlled test | 47.8% |
| First post-test check | 44.6% |
| Final recovery check | 1.36% |

**Finding:** The training workload caused a reproducible CPU utilization increase. The job completed and later CPU samples returned to a low idle level. The cause of the *intermediate* elevated CPU readings was not conclusively isolated.

## Resolution and operational safeguards

- **Resolution code:** Solution provided (for completion of the controlled training exercise).
- **Action:** Allow the temporary workload to finish; validate job state and monitor CPU until utilization normalizes.
- **Changes:** No persistent OS, registry, endpoint security, or service changes.
- **Validation:** Completed PowerShell job and low final CPU samples.
- **Distinction:** This is evidence of diagnostic method and recovery checking, not evidence of resolving an actual production device incident.

## SLA and ticket quality

ServiceNow displayed a **Priority 4 resolution (2 day)** SLA. In the verified *Resolved* screenshot, the SLA was **Paused**, with approximately **5 minutes** of business elapsed time (**0.18%** of its allowed target). The user later confirmed closing the ticket; confirm the **Completed** SLA stage using `SNOW-63` before describing the final SLA state as independently verified.

## Evidence index

Images are retained separately under:

`C:\Users\bazzi\Desktop\ServiceNow_HelpDesk_Lab_2026\09_Screenshots\`

| Screenshot | Description |
|---|---|
| `SNOW-54-INC05-Windows-Performance-Baseline.png` | CPU baseline, processor count, and timestamp |
| `SNOW-55-INC05-CPU-Workload-Simulation.png` | Elevated CPU samples and completed test job |
| `SNOW-56-INC05-CPU-Recovery-Verification.png` | Initial elevated post-test CPU samples (not yet recovered) |
| `SNOW-57-INC05-CPU-Recovery-Confirmed.png` | Final low CPU samples, completed job, UTC timestamp |
| `SNOW-58-INC05-Windows-Performance-New-Incident.png` | Incident form before submission |
| `SNOW-59-INC05-Windows-Performance-Submitted.png` | Submitted incident in progress |
| `SNOW-60-INC05-CPU-Troubleshooting-Work-Notes.png` | Technical findings posted to the activity log |
| `SNOW-61-INC05-CPU-Resolution-Details.png` | Resolution code and notes prior to resolution |
| `SNOW-62-INC05-CPU-Incident-Resolved.png` | Resolved state, recorded resolver, SLA paused |
| `SNOW-63-INC05-CPU-Incident-Closed-SLA.png` | User-reported final closure and SLA state; verify image before publication |

> Screenshots are evidence references, not embedded in this Markdown report. Redact account details and environment identifiers if the repository will be public. Never publish credentials, tokens, or recovery secrets.

## Skills demonstrated

- ServiceNow incident lifecycle and SLA interpretation
- Windows 11 endpoint troubleshooting
- CPU performance monitoring with PowerShell and Performance Counters
- Process-level investigation and interpretation of cumulative versus sampled CPU values
- Safe, bounded lab fault simulation
- Evidence collection with UTC timestamps
- Root-cause restraint: distinguish proven facts from unverified assumptions
- Validation of recovery before resolution

## Lessons learned

1. Obtain a baseline before attributing performance symptoms to a process.
2. A background job marked `Completed` does not by itself prove total CPU utilization has recovered.
3. Cumulative CPU time and current CPU utilization answer different questions.
4. Do not disrupt production services or endpoint security tooling merely to reduce resource usage.
5. Clearly distinguish simulated workloads, observable outcomes, and real user incidents in public portfolio documentation.

---

**Portfolio note:** This work was completed in a self-managed training lab using fictitious business personas. It does not represent work performed for an actual employer or a production customer.
