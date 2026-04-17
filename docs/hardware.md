![Giskard Hardware Architecture](./hardware-architecture.png)

# Giskard Hardware Architecture

## 1. Deployment Context

This document describes the hardware architecture for running the Giskard multi-agent swarm on:

- **Host:** Mac mini
- **Processor:** Apple Silicon **M5 Max**
- **Memory:** **256 GB unified memory**
- **Placement:** inside the protected home/personal subnet

Goal: run all core agents locally in a high-trust edge node while keeping latency low and avoiding dependence on external compute for critical defense decisions.

---

## 2. High-Level Hardware Topology

```mermaid
flowchart LR
    Internet((Internet))
    Router[Home Router / Firewall / DNS]
    Subnet[Home Subnet]
    Devices[Computers / Phones / Tablets / IoT]
    MacMini[Mac mini M5 Max 256GB<br/>Giskard Core Node]
    iPhone[iPhone App]

    Internet --> Router
    Router --> Subnet
    Subnet --> Devices
    Subnet --> MacMini

    Devices -->|telemetry + events| MacMini
    Router -->|gateway + DNS logs| MacMini
    MacMini -->|policy actions| Router
    MacMini -->|containment actions| Devices
    MacMini <--> |alerts + approvals| iPhone
```

---

## 3. Mac mini Node Architecture

The Mac mini hosts all primary control-plane and agent workloads locally.

```mermaid
flowchart TB
    subgraph MM["Mac mini (M5 Max, 256GB RAM)"]
      direction TB

      subgraph Ingest["Telemetry + Ingest Layer"]
        GW[Gateway/DNS Collector]
        EP[Endpoint Collector]
        MOB[Mobile/MDM Collector]
        IOT[IoT Discovery + Profile Collector]
      end

      subgraph Swarm["OpenClaw Agent Swarm"]
        N1[Network Sentinel Agent]
        N2[Endpoint Guard Agent]
        N3[Mobile Shield Agent]
        N4[IoT Watcher Agent]
        N5[Identity Defender Agent]
        N6[Deception Agent]
      end

      subgraph Orchestrator["Giskard Orchestrator"]
        C1[Correlation Agent]
        C2[Risk Scoring Agent]
        C3[Policy Agent]
        C4[Response Coordinator Agent]
        C5[Verification Agent]
      end

      subgraph Data["Data + Evidence"]
        DB[(Event Store)]
        EV[(Evidence Store)]
        AU[(Audit Timeline Store)]
      end

      subgraph UX["User Interface Services"]
        API[Mobile API Gateway]
        PUSH[APNs Provider Worker]
      end

      Ingest --> Swarm --> Orchestrator --> Data
      Orchestrator --> API --> PUSH
    end
```

---

## 4. Resource Partitioning (Recommended)

With 256 GB memory, use explicit resource pools so AI workloads cannot starve real-time defense loops.

## 4.1 Memory Budget (Initial)
- **OS + base services:** 24 GB
- **Ingest/collectors + stream processing:** 24 GB
- **OpenClaw domain agents:** 40 GB
- **Giskard orchestration agents:** 32 GB
- **Local LLM runtime (Ollama):** 80 GB
- **Event/evidence data services cache/buffers:** 32 GB
- **Operational headroom/spike reserve:** 24 GB

Total: **256 GB**

## 4.2 CPU/GPU Strategy (Apple Silicon)
- Pin ingestion, policy, and verification workers to high-priority CPU scheduling classes.
- Run LLM inference with bounded concurrency to protect deterministic control paths.
- Use separate worker pools:
  - **Realtime pool** (detect, policy, execution, verification)
  - **Reasoning pool** (LLM-assisted analysis/summarization)
  - **Batch pool** (reporting, model tuning, archival tasks)

## 4.3 Storage Layout (Suggested)
- Internal NVMe:
  - system + binaries
  - hot event index
  - short-horizon evidence cache
- External encrypted SSD/NAS (optional):
  - long-term evidence archives
  - snapshots/backups
  - incident export bundles

---

## 5. Network Placement and Interfaces

## 5.1 Position in Subnet
- Mac mini resides on trusted management segment/VLAN.
- It ingests telemetry from:
  - router/firewall
  - DNS resolver
  - endpoint/mobile/IoT connectors
- It issues controls to:
  - gateway ACL/firewall APIs
  - DNS blocklist/sinkhole controls
  - segmentation/quarantine controls

## 5.2 Connectivity Recommendations
- Prefer wired Ethernet for the Mac mini.
- Use static DHCP reservation or static IP.
- Restrict inbound access to admin and service ports only.
- Use mTLS for internal service-to-service traffic where feasible.

---

## 6. Execution Isolation Model

Run components in isolated units (containers/process supervisors) with least privilege:

- **Tier 1 (Critical Path):**
  - policy engine
  - response coordinator
  - verification
- **Tier 2 (Detection):**
  - domain monitoring agents
  - correlation/risk workers
- **Tier 3 (Auxiliary):**
  - reporting
  - model tuning
  - summarization

Rules:
- Tier 3 can never block Tier 1.
- LLM services cannot directly execute system/network actions.
- Only policy-approved command runners perform enforcement.

---

## 7. Reliability and Resilience

## 7.1 Runtime Resilience
- Supervisor restarts failed agent workers.
- Health checks for every agent and connector.
- Backpressure queues for burst events.
- Graceful degradation:
  - if LLM unavailable -> rule/policy-only mode
  - if external services unavailable -> local autonomous mode

## 7.2 Backup and Recovery
- Scheduled config and policy backups.
- Evidence/audit snapshots with integrity checks.
- Recovery runbook for node replacement and state restore.

---

## 8. Security Hardening for the Mac mini Node

- Full-disk encryption enabled.
- Signed/verified updates only.
- Minimal exposed services.
- Strict local firewall policy.
- Secrets in secure vault/Keychain-backed storage.
- Tamper-evident logs and immutable audit copies.
- Admin access restricted by role + MFA.

---

## 9. Operational Sizing Guidance

This hardware profile is sufficient for:
- full home subnet monitoring (computers, phones, tablets, IoT)
- parallel agent swarm execution
- local LLM-assisted incident reasoning
- near-real-time policy enforcement and verification

If sustained event rates increase significantly, scale by:
- adding a second in-subnet node for ingest/analytics split
- moving long-horizon storage/analytics to a secondary system
- keeping policy + response coordinator local on the primary node

---

## 10. Summary

The Mac mini (M5 Max, 256 GB RAM) acts as a powerful **local defense appliance** for Giskard:

- runs the full OpenClaw multi-agent swarm
- keeps critical decisions inside the home subnet
- provides resilient, low-latency protection for all device classes
- maintains secure iPhone-based user visibility and control through Giskard
