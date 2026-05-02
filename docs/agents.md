# OpenClaw Agent Swarm for Giskard

## 1. Overview

This document defines the **agent swarm** used in OpenClaw to implement Giskard's multi-agent home defense model.

Design intent:
- each agent has a narrow, well-defined mission
- agents monitor different parts of the environment continuously in parallel
- all findings and proposed actions flow to **Giskard Orchestrator**
- only Giskard communicates with the end user (iPhone app)
- defensive actions execute automatically under policy direction from the Giskard control agent

---

## 2. Swarm Topology

At a high level, OpenClaw runs:

1. **Domain Monitoring Agents** (network, endpoint, mobile, IoT, identity, deception)
2. **Decision and Control Agents** (correlation, risk, policy, response)
3. **Evidence and Learning Agents** (forensics, reporting, feedback)
4. **Interface Agent** (single user communication via Giskard)

All agents are independent workers with explicit contracts:
- input event schema
- output finding/action schema
- confidence score
- trace/audit metadata

---

## 3. Core Agents

### 3.1 Network Sentinel Agent
**Purpose:** Monitor gateway and subnet traffic for external and lateral threats.

**Monitors**
- firewall/gateway logs
- DNS queries and responses
- NetFlow and east-west patterns
- unusual outbound destinations

**Produces**
- suspicious flow alerts
- domain/IP block recommendations
- subnet segmentation/quarantine recommendations

---

### 3.2 Endpoint Guard Agent
**Purpose:** Defend laptops/desktops/servers on the subnet.

**Monitors**
- process tree anomalies
- privilege escalations
- suspicious file/system changes
- local auth anomalies

**Produces**
- process kill/suspend recommendations
- host isolation recommendations
- credential/session revocation suggestions

---

### 3.3 Mobile Shield Agent
**Purpose:** Protect phones and tablets connected to home/personal networks.

**Monitors**
- mobile posture signals (where available via MDM/UEM)
- risky app/network behavior
- suspicious DNS and outbound patterns from mobile devices
- authentication anomalies tied to mobile identities

**Produces**
- mobile segment quarantine recommendations
- risky destination blocking requests
- step-up auth and token revocation recommendations

---

### 3.4 IoT Watcher Agent
**Purpose:** Monitor unmanaged/smart-home devices with constrained visibility.

**Monitors**
- device fingerprint/profile drift
- abnormal east-west scanning behavior
- unexpected protocol/service use
- beaconing patterns

**Produces**
- IoT isolation/VLAN move recommendations
- protocol/port deny suggestions at gateway
- anomaly confidence and blast-radius estimates

---

### 3.5 Identity Defender Agent
**Purpose:** Detect account/session abuse across users and devices.

**Monitors**
- failed login bursts + success transitions
- impossible travel/time anomalies
- token/session reuse patterns
- privilege/role misuse

**Produces**
- session/token revoke actions
- forced MFA/step-up recommendations
- account lock or throttling recommendations

---

### 3.6 Deception Agent
**Purpose:** Use decoys/honeytokens to detect attacker interaction early.

**Monitors**
- access to decoy artifacts
- use of planted credentials/tokens
- interaction chains with high adversary confidence

**Produces**
- high-confidence intrusion findings
- targeted containment recommendations
- elevated risk weighting for correlated incidents

---

## 4. Orchestration and Decision Agents

### 4.1 Correlation Agent
**Purpose:** Merge findings from all domain agents into incident graphs.

**Responsibilities**
- deduplicate overlapping alerts
- connect events into attack chains
- map behavior to ATT&CK tactics/techniques

**Output**
- unified incident object with confidence + scope

---

### 4.2 Risk Scoring Agent
**Purpose:** Assign a normalized risk score for each incident.

**Inputs**
- agent confidence
- asset criticality
- privilege level
- blast radius
- identity impact

**Output**
- risk level: low, medium, high, critical

---

### 4.3 Policy Agent
**Purpose:** Determine what actions are allowed and appropriate.

**Responsibilities**
- enforce guardrails (least-risk, least-privilege)
- authorize automatic response execution by policy
- block forbidden commands/actions

**Output**
- executable action plan with constraints

---

### 4.4 Response Coordinator Agent
**Purpose:** Execute policy-authorized actions through controlled workflows.

**Execution model**
- Observe -> Evaluate -> Simulate -> Execute -> Verify -> Record

**Action classes**
- network blocks (IP/domain)
- host/device isolation
- process/session termination
- identity enforcement (MFA/re-auth)
- hardening updates (firewall/access rules)

---

### 4.5 Verification Agent
**Purpose:** Confirm actions had expected defensive effect.

**Checks**
- did malicious behavior stop?
- did risk score decrease?
- was collateral impact acceptable?

**Output**
- verified/partial/failed outcome + escalation hints

---

## 5. Evidence, Reporting, and Learning Agents

### 5.1 Forensics Agent
**Purpose:** Preserve evidence and maintain chain of custody.

**Captures**
- normalized/raw event records
- process/network metadata
- incident timelines and action logs

---

### 5.2 Reporting Agent
**Purpose:** Produce clear operator-facing incident narratives.

**Produces**
- incident summaries
- response timelines
- compliance/audit exports

---

### 5.3 Feedback and Tuning Agent
**Purpose:** Improve performance over time.

**Responsibilities**
- incorporate analyst outcomes
- tune detection thresholds/rules
- retrain anomaly models where applicable

---

## 6. Giskard Interface Agent (User-Facing Gateway)

This is the **only agent that talks to the end user**.

**Channels**
- iPhone app alerts and status updates
- executed-action summaries and verification results
- verification and audit summaries

**Rules**
- domain agents never communicate directly to user
- user-visible data is informational by default, not an operational approval gate
- all user-visible messages are normalized and explainable

---

## 7. OpenClaw Runtime Contracts

For every agent in the swarm, OpenClaw should define:

- `agent_id` and `role`
- accepted input schemas
- produced output schemas
- confidence scoring format
- timeout/retry policy
- escalation policy
- audit event format

Recommended shared fields:
- `incident_id`
- `asset_id`
- `subnet_id`
- `confidence`
- `risk_level`
- `recommended_actions[]`
- `evidence_refs[]`
- `trace_id`

---

## 8. Minimum Swarm for MVP

If starting lean, use this initial set:

1. Network Sentinel Agent
2. Endpoint Guard Agent
3. Mobile Shield Agent
4. Correlation Agent
5. Risk Scoring Agent
6. Policy Agent
7. Response Coordinator Agent
8. Verification Agent
9. Giskard Interface Agent

Then add IoT/Identity/Deception/Forensics/Feedback agents iteratively.

---

## 9. Summary

OpenClaw enables Giskard as a **coordinated defensive swarm**:
- specialized agents monitor distinct domains in parallel
- orchestration agents make deterministic, policy-safe decisions
- evidence and learning agents improve quality over time
- Giskard remains the single, trusted user interface through iPhone
