# Zeroth Guard Implementation Plan for OpenClaw Subnet Deployment

## 1. Purpose and Outcome

This plan defines the step-by-step implementation required to run Zeroth Guard on an OpenClaw runtime inside a protected network subnet, while protecting:

- the Mac-based control node running Zeroth Guard
- all systems on the same subnet (computers, phones/tablets, IoT)
- selected target macOS hosts through managed installation and policy enrollment

It also includes the iOS app scope for management, configuration, action visibility, and secure macOS installer orchestration.

---

## 2. Target Deployment Model

### 2.1 Core Topology
- **Control node:** Mac mini (Apple Silicon) in trusted management VLAN/segment
- **Runtime:** OpenClaw multi-agent swarm + Zeroth Guard orchestrator
- **Data path:** local ingest, detection, policy, response, verification, evidence/audit
- **Control path:** router/firewall/DNS adapters for subnet-wide enforcement
- **User path:** iOS app is the only operator-facing interface

### 2.2 Security Boundary Goals
- Keep critical detection and response local-first inside subnet
- Minimize exposed interfaces and enforce mTLS between internal services
- Ensure autonomous operation during internet outage/degraded external dependencies
- Preserve evidence and audit trail for all automated and manual actions

---

## 3. Delivery Phases (Execution Roadmap)

## Phase 0 - Program Setup and Architecture Freeze

### Step 0.1 - Freeze MVP scope and acceptance criteria
- Approve initial threat scenarios:
  - suspicious DNS/C2 beaconing
  - lateral scanning within LAN
  - credential abuse behavior
- Approve initial automated actions:
  - block domain/IP at DNS/gateway
  - isolate/quarantine device segment
  - force re-auth or revoke session/token (where integrated)
- Define Definition of Done for end-to-end flow (detect -> respond -> verify -> report in iOS)

### Step 0.2 - Define interface contracts
- Publish common schemas for:
  - agent findings
  - incident objects
  - action requests/results
  - verification outcomes
  - audit events
- Include required correlation fields (`incident_id`, `asset_id`, `subnet_id`, `trace_id`)

### Step 0.3 - Set baseline architecture decisions
- Realtime channel: SSE or WebSocket
- Data stores: event/evidence/audit retention and backup strategy
- Local process isolation model by criticality tier
- iOS distribution strategy (App Store/TestFlight/MDM)

---

## Phase 1 - Subnet Foundation and Hardening

### Step 1.1 - Prepare OpenClaw control node (Mac mini)
- Install hardened base OS and enable full-disk encryption
- Configure local firewall allow-list
- Restrict administrative access (role + MFA)
- Configure secure secret storage (Keychain-backed or vault integration)

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

### Step 2.2 - Implement minimum MVP agent set
- Network Sentinel Agent
- Endpoint Guard Agent
- Mobile Shield Agent
- Correlation Agent
- Risk Scoring Agent
- Policy Agent
- Response Coordinator Agent
- Verification Agent
- Zeroth Guard Interface Agent

### Step 2.3 - Implement guarded command pipeline
- Enforce workflow:
  - Observe -> Evaluate -> Simulate -> Execute -> Verify -> Record
- Add action safety controls:
  - policy pre-check
  - blast-radius estimate
  - time-bounded execution
  - rollback recommendations for failed verification

### Step 2.4 - Implement first complete attack scenario
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

- **E1:** Control node hardening and network placement
- **E2:** Ingest, normalization, and inventory baseline
- **E3:** OpenClaw MVP agent swarm and orchestration
- **E4:** Policy-safe action runner and verification engine
- **E5:** Subnet enforcement adapters (gateway, DNS, segmentation)
- **E6:** iOS app (auth, incident, devices, actions, audit, settings)
- **E7:** macOS installer packaging, enrollment, and lifecycle management
- **E8:** Evidence, audit, retention, and export
- **E9:** Reliability, security testing, and production launch

---

## 5. Recommended Milestones

- **Milestone 1:** First autonomous vertical slice operational in lab subnet
- **Milestone 2:** Subnet segmentation + multi-device coverage validated
- **Milestone 3:** iOS management/configuration + realtime status complete
- **Milestone 4:** iOS-driven macOS install/enrollment workflow complete
- **Milestone 5:** Production hardening and go-live signoff

---

## 6. Definition of Done (Implementation Plan Complete)

The implementation is complete when all are true:

- OpenClaw runtime runs stably on in-subnet Mac control node
- Protected subnet systems receive active monitoring and policy-safe automated defense
- Lateral movement and C2-style scenarios are detected, contained, verified, and audited
- iOS app is the primary management/configuration and response visibility interface
- iOS app can initiate and track secure installation/enrollment on target macOS hosts
- Every defensive action is traceable through verification and immutable audit records

