# Zeroth Guard Implementation Plan for OpenClaw Subnet Deployment

## 1. Purpose and Outcome

This plan defines the step-by-step implementation required to run Zeroth Guard on an **in-subnet computer** that **hosts the OpenClaw software** (gateway + agent runtime). That host is configured with **security agents** (defense personas in the OpenClaw swarm), **guarded tools** (OpenClaw built-ins under strict allowlists plus repo-native wrappers such as Network Pulse), and **workspace skills** (optional `skills/` bundles and ClawHub installs reviewed by the operator). Together they protect:

- the **OpenClaw host** itself (hardened control node)
- **all systems on the same home or small-office subnet** (computers, phones/tablets, IoT)
- **selected target macOS hosts** through managed installation and policy enrollment

It also includes the iOS app scope for management, configuration, action visibility, and secure macOS installer orchestration.

---

## 2. Target Deployment Model

### 2.1 Core Topology — one computer hosts OpenClaw for the subnet

Zeroth Guard assumes a **single primary control computer** on the protected LAN that runs **OpenClaw** end to end: gateway, sessions, tool execution under policy, and the **multi-agent swarm** that implements domain monitoring and orchestrated response. The **Zeroth Guard orchestrator** (control plane logic) correlates swarm output, applies policy, and is the only path to **customer-facing** reporting on the iPhone app.

| Layer | Role | Typical location on the host |
|--------|------|--------------------------------|
| **OpenClaw gateway / runtime** | Process management, tool routing, `exec` approvals, optional local LLM hooks | Control node OS (macOS reference: Mac mini; **prototype:** Ubuntu laptop per `docs/hardware.md` §1.1) |
| **Security agents** | Network, endpoint, mobile, IoT, identity, deception, correlation, policy, response, verification personas | OpenClaw agent definitions (`agents/`, `agents/swarm-manifest.yaml`, `agents/roles/`) |
| **Tools** | Deterministic adapters: built-ins allowlisted in **`tools/openclaw/zeroth-guard-openclaw-tools.yaml`**, plus **executable wrappers** under **`tools/`** (e.g. **`tools/network_pulse/wrapper.py`** → `external/network-scan-agent`) | Same host; subprocesses and APIs reachable from the gateway |
| **Skills** | Optional **AgentSkills**-style guidance and install pointers under **`skills/`**; third-party skill code only after operator review | Injected per OpenClaw skills precedence; not a bypass for policy |

Concrete topology:

- **Control node:** **Mac mini (Apple Silicon)** in a trusted management VLAN/segment — **production reference** (`docs/hardware.md`).
- **Bring-up / lab node (optional):** **Ubuntu 26.04** workstation-class laptop for early integration — **lower concurrency and RAM/VRAM** than the Mac mini profile; same *logical* role (OpenClaw host for the subnet).
- **Runtime:** **OpenClaw** runs the **security agent swarm**; **Zeroth Guard** orchestration and correlation sit in the same trust boundary on that host (or tightly bound services you define during implementation).
- **Data path:** local ingest, detection, policy, response, verification, evidence/audit on the control node (and attached storage as designed).
- **Control path:** router/firewall/DNS adapters for subnet-wide enforcement (invoked by agents/tools under policy).
- **User path:** **Zeroth Guard Mobile (iOS)** is the only **customer-facing** interface for incidents, audit, and sensitive confirmations (optional operator web UIs remain non-customer per `docs/architecture.md`).

### 2.2 Security Boundary Goals
- Keep critical detection and response local-first inside subnet
- Minimize exposed interfaces and enforce mTLS between internal services
- Ensure autonomous operation during internet outage/degraded external dependencies
- Preserve evidence and audit trail for all automated and manual actions

### 2.3 How agents, tools, and skills map to OpenClaw on the host

Use this checklist when implementing or auditing the control node:

1. **Install and pin OpenClaw** on the host (version, config directory, service user). Document upgrade and rollback.
2. **Load security agents** from this repository’s OpenClaw-facing artifacts: swarm manifest, role prompts, and persona docs (`agents/README.md`, `agents/swarm-manifest.yaml`, `agents/roles/`, `agents/SOUL.md`, `agents/AGENTS.md`). Ensure each defense agent has an explicit **tool allowlist** and **exec** boundaries.
3. **Register tools:** merge **`tools/openclaw/zeroth-guard-openclaw-tools.yaml`** (and project-specific additions) with the gateway’s **`tools.allow` / `tools.deny` / `tools.profile`** so autonomous agents get **`exec`** (tight), **`cron`**, **`read`/`write`/`edit`** on designated paths, **`web_search`/`web_fetch`** (sanitized), and **deny-by-default** high-risk tools (`browser`, `gateway`, `message`, etc.) unless an operator-only persona requires them.
4. **Wire repo wrappers:** install dependencies for **`tools/network_pulse/`** (Network Pulse → `external/network-scan-agent` submodule), schedule **`pulse`** vs on-demand **`deep`**, and map JSON output into your normalized finding schema.
5. **Curate skills:** enable only reviewed **`skills/*/SKILL.md`** bundles; use **`openclaw skills install`** for ClawHub content only after operator sign-off. Treat skills as **prompt + integration guidance**, not a substitute for policy on **`exec`** and enforcement.

See **`docs/architecture.md`** for the full platform view (orchestrator, agent swarm, tools, skills, and Network Pulse).

---

## 3. Delivery Phases (Execution Roadmap)

> **Progress legend:** `✅` = **completed in this repository** (committed docs, schemas, or repo artifacts). Bullets **without** `✅` are not yet done for a **live** OpenClaw deployment (runtime install, integrations, or product code on devices).

## Phase 0 - Program Setup and Architecture Freeze ✅

### Step 0.1 - Freeze MVP scope and acceptance criteria ✅
- ✅ Capture the frozen MVP definition in **`docs/phase0_acceptance_criteria.md`**.
- ✅ Approve initial threat scenarios:
  - ✅ suspicious DNS/C2 beaconing
  - ✅ lateral scanning within LAN
  - ✅ credential abuse behavior
- ✅ Approve initial automated actions:
  - ✅ block domain/IP at DNS/gateway
  - ✅ isolate/quarantine device segment
  - ✅ force re-auth or revoke session/token (where integrated)
- ✅ Define Definition of Done for end-to-end flow (detect -> respond -> verify -> report in iOS)

### Step 0.2 - Define interface contracts ✅
- ✅ Publish schemas in **`schemas/`** and a short guide at **`docs/interface_contracts.md`**.
- ✅ Publish common schemas for:
  - ✅ agent findings
  - ✅ incident objects
  - ✅ action requests/results
  - ✅ verification outcomes
  - ✅ audit events
- ✅ Include required correlation fields (`incident_id`, `asset_id`, `subnet_id`, `trace_id`)

### Step 0.3 - Set baseline architecture decisions ✅
- ✅ Record the frozen defaults in **`docs/phase0_baseline_decisions.md`**.
- ✅ Realtime channel: SSE or WebSocket
- ✅ Data stores: event/evidence/audit retention and backup strategy
- ✅ Local process isolation model by criticality tier
- ✅ iOS distribution strategy (App Store/TestFlight/MDM)
- ✅ **OpenClaw on the control computer:** gateway layout, workspace layout, **`tools` allow/deny defaults** (see **`tools/openclaw/zeroth-guard-openclaw-tools.yaml`**), which **`skills/`** bundles are in scope for MVP, and how **`external/network-scan-agent`** + **`tools/network_pulse/`** are deployed on that host

---

## Phase 1 - Subnet Foundation and Hardening

### Step 1.1 - Prepare OpenClaw host (Mac mini production path; Ubuntu prototype path)
- Install hardened base OS and enable full-disk encryption
- Configure local firewall allow-list
- Restrict administrative access (role + MFA)
- Configure secure secret storage (Keychain-backed or vault integration)
- **Install OpenClaw** (gateway/runtime) as a supervised service; create a dedicated service account with least privilege for agent workloads
- **Bootstrap OpenClaw configuration:** workspace root, logging, optional MCP servers, and **baseline `tools` profile** aligned with **`tools/openclaw/zeroth-guard-openclaw-tools.yaml`**
- **Clone or deploy this monorepo** on the host (or mount it read-only where appropriate) so **`agents/`**, **`tools/`**, **`skills/`**, and **`external/network-scan-agent`** are available to the runtime

### Step 1.2 - Place node in secure network position
- Assign static IP/DHCP reservation in management segment
- Verify reliable wired connectivity
- Restrict inbound ports to required service/API endpoints only
- Establish outbound allow-list for required integrations (IdP/APNs/updates)

### Step 1.3 - Build trust and service identity
- Establish PKI and issue service certificates
- Enforce mTLS for internal service-to-service communication
- Configure certificate rotation and revocation checks

### Step 1.4 - Set resilience baseline
- Add supervisor for all critical services
- Configure health checks, restart policy, and backpressure queues
- Define graceful degradation mode:
  - no LLM -> rules/policy-only mode
  - no internet -> local autonomous mode

---

## Phase 2 - Core OpenClaw Runtime (Vertical Slice #1)

### Step 2.1 - Implement telemetry ingestion
- Integrate gateway/firewall log collection
- Integrate DNS visibility + control adapter
- Integrate DHCP/ARP inventory for subnet asset baseline
- Normalize telemetry into shared event schema
- **On the OpenClaw host**, expose ingested streams to agents via **`read`** / **`exec`** (tailers, journal queries) or small collector processes—keep paths and credentials scoped per agent role

### Step 2.2 - Configure security agents on OpenClaw (minimum MVP set)
Implement and **register** the following as OpenClaw-managed defense personas (names align with `docs/architecture.md` / `agents/`):

- Network Sentinel Agent
- Endpoint Guard Agent
- Mobile Shield Agent
- Correlation Agent
- Risk Scoring Agent
- Policy Agent
- Response Coordinator Agent
- Verification Agent
- Zeroth Guard Interface Agent

**Implementation notes:**

- Bind each agent to the **swarm manifest** and **role** docs so prompts, schedules, and **tool allowlists** stay consistent.
- Prefer **`tools/network_pulse/wrapper.py --mode pulse`** (scheduled) and **`deep`** only under policy for inventory refresh and drift signals.
- Add **`cron`** entries on the host for periodic pulse if not delegated entirely inside OpenClaw.

### Step 2.3 - Register tools and skills on the OpenClaw host
- **Tools:** finalize **`tools/openclaw/zeroth-guard-openclaw-tools.yaml`** against the OpenClaw version you ship; wire **`exec`** approvals for wrappers under **`tools/`**; smoke-test **`zerothguard.network_pulse`** end to end.
- **Skills:** document which **`skills/`** bundles are enabled in MVP; for any ClawHub install, record version, trust review, and revocation procedure.
- **LLM (optional):** if using local inference on the same host (e.g. Ollama), cap concurrency and memory so agent loops and Network Pulse remain stable (see `docs/hardware.md` for prototype vs Mac mini sizing).

### Step 2.4 - Implement guarded command pipeline
- Enforce workflow:
  - Observe -> Evaluate -> Simulate -> Execute -> Verify -> Record
- Add action safety controls:
  - policy pre-check
  - blast-radius estimate
  - time-bounded execution
  - rollback recommendations for failed verification

### Step 2.5 - Implement first complete attack scenario
- Choose suspicious DNS/C2 flow as first scenario
- Required behavior:
  - detect high-risk domain activity
  - create incident with risk score
  - automatically block at DNS/gateway by policy
  - verify outbound behavior stopped
  - write complete audit timeline

---

## Phase 3 - Subnet-Wide Protection Expansion

### Step 3.1 - Add segmentation and quarantine controls
- Implement VLAN/SSID quarantine actions
- Add device-level subnet placement changes through gateway integrations
- Enforce trusted/untrusted segment policies

### Step 3.2 - Add broader device coverage
- Expand endpoint coverage for macOS targets
- Expand mobile/tablet posture ingestion (via available MDM/UEM signals)
- Expand IoT profiling (device fingerprint drift + scanning behavior)

### Step 3.3 - Add identity-aware enforcement
- Integrate IdP session/token telemetry
- Implement forced MFA and session revocation actions
- Correlate identity risk with device/subnet incident risk

### Step 3.4 - Add anti-lateral movement controls
- Detect east-west scan patterns and unusual protocol/service pivoting
- Trigger subnet deny rules and targeted isolation
- Verify threat containment and collateral impact thresholds

---

## Phase 4 - iOS Management and Configuration App

### Step 4.1 - Build secure authentication and enrollment
- Implement OIDC + MFA login
- Add device binding and trust registration
- Store credentials in Keychain (Secure Enclave-backed keys where possible)

### Step 4.2 - Implement operations visibility screens
- Incident feed (severity/status filters)
- Incident detail (timeline, impact, action rationale)
- Devices view (computers/phones/tablets/IoT, trust posture)
- Audit timeline (human + autonomous actions, policy reason, verification status)

### Step 4.3 - Implement management and configuration features
- Subnet configuration view:
  - segment definitions (trusted/guest/quarantine)
  - DNS/gateway adapter status
  - policy profile assignment per subnet
- Agent runtime view:
  - service health
  - ingest lag
  - action queue and verification state
- Notification preferences and escalation rules

### Step 4.4 - Implement action control and safety UX
- Display policy-authorized automatic actions and outcomes
- Add controlled manual override path for exceptional policy modes
- Require biometric gate + signed nonce for sensitive action submission
- Show impact preview and rollback guidance before sensitive operations

### Step 4.5 - Implement realtime delivery
- APNs for high-signal incident notifications (minimal metadata only)
- Realtime stream (SSE/WebSocket) for action status and verification updates
- Confirm end-to-end latency targets from detect -> mobile visibility

---

## Phase 5 - macOS Target Installation and Enrollment Workflow

### Step 5.1 - Build macOS installer package
- Create signed and notarized macOS installer (`pkg`)
- Install components:
  - endpoint collector/agent
  - local policy client
  - secure service configuration
- Add uninstall and repair scripts

### Step 5.2 - Implement secure bootstrap flow
- On first launch, installer obtains one-time enrollment token
- Perform mutual attestation between target host and control node
- Bind target host to subnet + asset identity in orchestrator inventory
- Rotate bootstrap secret immediately after enrollment

### Step 5.3 - Add iOS-driven installation orchestration
- In iOS app, add "Install on macOS Device" flow:
  - register target host intent
  - generate short-lived enrollment package/link/token
  - track install state (`pending`, `installing`, `enrolled`, `failed`)
- Show guided remediation for failed installation states

### Step 5.4 - Enforce post-install hardening profile
- Apply baseline local firewall and service restrictions
- Validate endpoint telemetry and policy heartbeat
- Require successful verification before marking host as protected

---

## Phase 6 - Data, Audit, and Forensic Readiness

### Step 6.1 - Implement tamper-resistant evidence pipeline
- Persist normalized events, action records, and verification outcomes
- Maintain immutable audit timeline copies
- Add integrity checks for archived evidence bundles

### Step 6.2 - Add incident and compliance exports
- Export case timeline and action log bundles
- Provide operator-readable summaries + machine-readable artifacts
- Implement retention/expiry policies with legal/compliance profiles

---

## Phase 7 - Validation, Red Teaming, and Production Readiness

### Step 7.1 - Functional validation
- Execute each supported threat scenario in lab subnet
- Confirm action policy behavior by risk tier
- Confirm verification state transitions (`verified`, `partial`, `failed`)

### Step 7.2 - Safety and reliability validation
- Test false-positive handling and action reversibility
- Test service crash/restart and degraded operation modes
- Test loss of internet and restoration scenarios

### Step 7.3 - Security validation
- Pen-test iOS API flows and installer bootstrap path
- Validate cert pinning, nonce replay defense, and token rotation
- Validate least-privilege permissions for all runtime components

### Step 7.4 - Go-live checklist
- Runbook complete (incident handling, rollback, recovery)
- Monitoring dashboard and on-call alerts in place
- Backups and disaster recovery tested
- Operator training completed via iOS workflow

---

## 4. Backlog Structure (Epics and Workstreams)

Create and track implementation under these epics:

- **E1:** OpenClaw host hardening, network placement, and OpenClaw install/service baseline
- **E2:** Ingest, normalization, and inventory baseline (including Network Pulse / gateway paths on the host)
- **E3:** OpenClaw MVP **security agent** swarm, manifests, and orchestration on the control node
- **E3a:** Tool registry, **`exec`** allowlists, and repo **wrappers** (`tools/`, `external/network-scan-agent`)
- **E3b:** Workspace **skills** enablement and ClawHub governance (`skills/`)
- **E4:** Policy-safe action runner and verification engine
- **E5:** Subnet enforcement adapters (gateway, DNS, segmentation)
- **E6:** iOS app (auth, incident, devices, actions, audit, settings)
- **E7:** macOS installer packaging, enrollment, and lifecycle management
- **E8:** Evidence, audit, retention, and export
- **E9:** Reliability, security testing, and production launch

---

## 5. Recommended Milestones

- **Milestone 1:** **OpenClaw host** provisioned with MVP **security agents**, **tool** registry + **`exec`** wiring, and reviewed **skills**; first autonomous vertical slice operational in lab subnet
- **Milestone 2:** Subnet segmentation + multi-device coverage validated
- **Milestone 3:** iOS management/configuration + realtime status complete
- **Milestone 4:** iOS-driven macOS install/enrollment workflow complete
- **Milestone 5:** Production hardening and go-live signoff

---

## 6. Definition of Done (Implementation Plan Complete)

The implementation is complete when all are true:

- **OpenClaw** runs stably on the **in-subnet control computer** (Mac mini reference or approved prototype hardware), with **security agents**, **registered tools**, and **operator-approved skills** configured per policy
- Protected subnet systems receive active monitoring and policy-safe automated defense
- Lateral movement and C2-style scenarios are detected, contained, verified, and audited
- **Zeroth Guard Mobile** is the **customer-facing** management, configuration, and response visibility interface (per `docs/architecture.md`)
- iOS app can initiate and track secure installation/enrollment on target macOS hosts
- Every defensive action is traceable through verification and immutable audit records

