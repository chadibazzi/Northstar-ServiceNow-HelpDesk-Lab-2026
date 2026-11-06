# Lab architecture

```mermaid
flowchart LR
    U["Fictional employees / test callers"] --> SN["ServiceNow Zurich PDI (cloud)"]
    T1["Northstar Tier 1 · Alex Morgan"] --> SN
    T2["Northstar Tier 2 · Jordan Reed"] --> SN
    SOC["Northstar SOC · Taylor Brooks"] --> SN
    WIN["WIN11-CLIENT01 · Windows 11 VM"] <-->|"AD authentication / SMB"| DC["DC01 · corp.local · AD/DNS/SMB"]
    WIN -->|"Wazuh agent 002"| W["WAZUH01 · manager"]
    DC -->|"Wazuh agent 001"| W
    WIN --> SY["Sysmon · local Event ID 1"]
    SY -. "collection configured; test-event ingestion not verified" .-> W
    T1 --> WIN
    T1 --> DC
    T1 -. escalation .-> T2
    T1 -. escalation .-> SOC
```

**Boundaries:** diagram represents a training environment, not a production network. ServiceNow PDI tasks and lab-host events were manually correlated; no ServiceNow-to-Active-Directory integration or automated SOC ticket creation was demonstrated.

**Note:** The two Windows virtual NICs and other VirtualBox adapters are simplified here; this diagram is logical rather than a precise Layer 2 network map.
