# Incident 010 — PowerShell Process Investigation and SOC Escalation

**Project:** ServiceNow Help Desk Lab Project — 2026  
**Organization:** Northstar (fictional training environment)  
**ServiceNow record:** `INC0010009`  
**Final documented state:** On Hold — Awaiting Problem  
**Assigned group / analyst:** Northstar - SOC Security / Taylor Brooks  
**Initial Tier 1 technician:** Alex Morgan  
**Priority:** 4 — Low  
**Environment:** WIN11-CLIENT01, WAZUH01, Microsoft Sysmon, Wazuh 4.14.7

> **Training-only disclosure:** This scenario contains a deliberately generated, harmless PowerShell process. It does not demonstrate an intrusion, unauthorized PowerShell execution, credential theft, or confirmed compromise. The named Northstar staff and incident narrative are fictional. The process itself was run by `CORP\Administrator`, not by the fictional caller Olivia Bennett.

## Executive summary

Tier 1 verified local evidence of a controlled PowerShell process on WIN11-CLIENT01 using Microsoft Sysmon Event ID 1. Wazuh Agent `002` was active, but the unique test marker could not be located in the Wazuh manager's searched `alerts.json` or `archives.json` files. The manager also displayed indexer-connector warnings about unavailable servers. These observations warrant additional telemetry and indexing checks but do not prove why the specific event was absent from the searches. Tier 1 documented the facts and escalated the record to Northstar - SOC Security. The incident remains On Hold — Awaiting Problem pending review.

## Lab scope and roles

| Role | Training identity |
| --- | --- |
| Fictional caller | Olivia Bennett |
| Tier 1 technician | Alex Morgan |
| SOC escalation owner | Taylor Brooks |
| Endpoint execution account | `CORP\Administrator` |
| Windows host | `WIN11-CLIENT01` |
| Wazuh manager | `wazuh01` |
| Wazuh Windows agent | ID `002` |

## Technical timeline and evidence

| Time (UTC, 2026-11-06) | Event / observation |
| --- | --- |
| 17:42–17:43 | Wazuh Windows service running; Wazuh manager active; agents `001` DC01 and `002` WIN11-CLIENT01 active. Windows PowerShell Operational log enabled. |
| 17:44–17:49 | Local Wazuh agent configuration inspected and extended for PowerShell Operational Event IDs 4103 and 4104. XML parsed; local backup confirmed. This did **not** prove ingestion. |
| 17:51:08 | Wazuh agent `002` reported `Active`. |
| 17:52–17:55 | Safe interactive PowerShell test marker did not appear in searched local Event ID 4104 records. Subsequent checks confirmed two recent 4104 warnings and active Sysmon. |
| 17:56 | Sysmon Event ID 1 process creation records verified locally. |
| **17:57:24.711** | Controlled PowerShell child process created; Sysmon Event ID 1, Record ID **1382342** captured. |
| 17:58:57 | `alerts.json` and `archives.json` confirmed present. Test marker not found by direct file search. |
| 18:03:57 | Wazuh archive contained Agent `002` entries for SCA/rootcheck; exact-string searches did not identify the test Sysmon event. Manager logs contained indexer availability warnings. |
| Later in ServiceNow | `INC0010009` created, Tier 1 notes posted, reassigned to Northstar - SOC Security / Taylor Brooks, then placed On Hold — Awaiting Problem. |

## Verified Sysmon event

- **Channel:** `Microsoft-Windows-Sysmon/Operational`
- **Event ID:** `1` (Process Create)
- **Record ID:** `1382342`
- **Event UTC:** `2026-11-06 17:57:24.711`
- **Process image:** `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- **Process ID:** `7660`
- **User:** `CORP\Administrator`
- **Integrity level:** `High`
- **Parent image:** `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- **Parent process ID:** `9828`
- **Unique test marker:** `NORTHSTAR-INC010-SYSMON-TEST`

The child process was intentionally invoked with `-NoProfile` and a command that printed the marker and called `Get-Date`. This is benign test activity; the event demonstrates process telemetry, not threat detection.

## Wazuh investigation

**Confirmed:** Wazuh manager was active; endpoint agent `002` was connected; `alerts.json` and `archives.json` existed; archive records from endpoint agent `002` were present. Agent configuration contained a Sysmon Operational event-channel entry. The test marker was **not** found in the two searched files.

**Additional finding:** The manager's `ossec.log` contained repeated `indexer-connector: WARNING: Failed to sync agent ... No available server` messages. This is evidence of an indexer connectivity concern at that time, but it cannot by itself establish the reason for missing Sysmon telemetry.

**Not established:** That the test event was ingested; that it was dropped; that a Wazuh detection rule fired; or that an indexer problem caused the local search result. These remain questions for SOC follow-up.

## Tier 1 handling and escalation

1. Collected Windows host and Sysmon process evidence with UTC timestamps.
2. Confirmed agent connectivity and checked Wazuh manager alert/archive locations.
3. Recorded absence of the unique marker in those searches without claiming ingestion failure as proven.
4. Documented the indexer-connector warnings as a separate concern.
5. Added technical and escalation work notes to ServiceNow.
6. Reassigned `INC0010009` from **Northstar - Tier 1 Help Desk / Alex Morgan** to **Northstar - SOC Security / Taylor Brooks**.
7. Left the record **On Hold — Awaiting Problem** for follow-up; did not close or falsely resolve it.

## SOC follow-up checklist

- [ ] Confirm Windows Sysmon Event ID 1 collection/forwarding from agent `002`.
- [ ] Determine whether Sysmon Record ID `1382342` reached the manager, using reliable parsed fields and event-time bounds.
- [ ] Review the endpoint agent and manager logcollector diagnostics.
- [ ] Check PowerShell process creation detection rules and intended alert thresholds.
- [ ] Independently diagnose Wazuh indexer availability and indexing health.
- [ ] Record a final SOC disposition and any approved remediation before resolving the incident.

## Screenshot evidence map

Screenshots are maintained in the project evidence directory. Use the names below as references; they are **not embedded** in this Markdown file.

| Screenshot | Filename | Evidence |
| --- | --- | --- |
| 108 | `SNOW-108-INC10-Wazuh-PowerShell-Logging-Configured.png` | Wazuh configuration backup and XML parse. |
| 109 | `SNOW-109-INC10-Wazuh-Agent-Reconnected.png` | Wazuh Agent `002` active. |
| 110 | `SNOW-110-INC10-Sysmon-PowerShell-Process-Evidence.png` | Sysmon Event ID 1 process, command line, user, UTC time. |
| 111 | `SNOW-111-INC10-PowerShell-SOC-New-Incident.png` | New incident form. |
| 112 | `SNOW-112-INC10-PowerShell-SOC-Incident-Submitted.png` | Submitted incident, Tier 1 assignment and SLA. |
| 113 | `SNOW-113-INC10-PowerShell-Tier1-Investigation-Work-Notes.png` | Tier 1 work notes saved. |
| 114 | `SNOW-114-INC10-PowerShell-SOC-Escalation.png` | SOC assignment and escalation notes. |
| 115 | `SNOW-115-INC10-PowerShell-SOC-On-Hold.png` | On Hold — Awaiting Problem, SOC owner, notes. |

**Local screenshot directory:** `C:\Users\bazzi\Desktop\ServiceNow_HelpDesk_Lab_2026\09_Screenshots\`

## Portfolio learning outcomes

- Correlated a Windows PowerShell process with Sysmon process creation evidence.
- Interpreted process user, integrity, parent process and command-line data.
- Distinguished agent connectivity from confirmed ingestion and confirmed detection.
- Identified and responsibly documented a SIEM visibility gap without overstating causality.
- Practiced ServiceNow incident lifecycle, internal work notes, Tier 1-to-SOC handoff, and accurate pending disposition.

## Final disposition

**Tier 1 work: completed. SOC handoff: completed. Monitoring investigation: pending.** `INC0010009` remains **On Hold — Awaiting Problem**, assigned to Northstar - SOC Security / Taylor Brooks. No production attack or confirmed compromise was involved.
