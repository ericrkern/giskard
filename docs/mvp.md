# Zeroth Guard MVP Plan

## 1. MVP Goal

Build the smallest end-to-end version of Zeroth Guard that can:

- detect a real threat pattern on a home subnet
- execute a safe automatic defensive action under policy guardrails
- verify that action succeeded
- present alert, action, and verification status in the iPhone app

Software bring-up may start on the **development laptop** running **Ubuntu 26.04** (Intel i9-14900HX, NVIDIA RTX 4070 Laptop 8 GB VRAM, 32 GB RAM, 1 TB storage—see `docs/hardware.md` §1.1). The **stable MVP target** remains an in-subnet **Mac mini** node as described in that document.

---

## 2. Where To Start

### 2.1 Define Success Criteria (1 page)
- Protect one home subnet
- Cover device visibility for computers + phones/tablets
- Detect 2-3 threat patterns
- Execute 2-3 automatic policy-authorized response actions
- Show full incident + action + verification flow in iOS app

### 2.2 Build One Vertical Slice First
Implement this sequence before broadening scope:

1. Telemetry ingest
2. Detection
3. Risk + policy decision
4. Action execution
5. Verification
6. iPhone alert + operator view

Recommended first scenario:
- suspicious outbound C2/phishing domain from a subnet device

### 2.3 Keep MVP Local-First
- Run control plane + agent swarm on the prototype laptop first if needed, then on the Mac mini home node
- Size workloads for **32 GB RAM** and **8 GB VRAM** during prototype (smaller models, fewer concurrent agents than the 256 GB reference)
- Avoid unnecessary cloud dependencies in MVP
- Add remote/hybrid components after local loop is stable

---

## 3. What You Need (MVP Components)

### 3.1 Core Security Pipeline
- Gateway integration (router/firewall telemetry + controls)
- DNS visibility and block controls
- Device inventory (DHCP/ARP + basic profiling)
- Rule-based detection engine
- Policy engine with explicit allow/deny action matrix
- Guarded action runner (policy-authorized automatic actions only)
- Verification module for outcome checks
- Audit timeline + evidence store

### 3.2 iOS Companion App
- OIDC + MFA login
- Incident feed
- Incident detail (timeline + recommended action)
- Action confirmation (biometric gate for sensitive actions)
- Audit/status view
- APNs push notifications

### 3.3 Infrastructure and Runtime
- **Prototype host OS:** Ubuntu 26.04 on the development laptop (see `docs/hardware.md` §1.1)
- Process supervision (services/containers)
- Primary datastore for incidents and audit (e.g., Postgres)
- Optional message bus (can defer in early MVP)
- Secrets handling + TLS
- Basic observability (logs, metrics, health checks)

---

## 4. Recommended MVP Scope

### 4.1 Detection Use Cases (pick 3)
- Credential stuffing behavior pattern
- Suspicious DNS/C2 beaconing
- Lateral scan behavior inside LAN

### 4.2 Automated Actions (pick 3)
- Block domain/IP at DNS or gateway firewall
- Quarantine device into restricted segment/VLAN
- Force step-up authentication / revoke session token (where integrated)

### 4.3 Minimum Agent Set
- Network Sentinel Agent
- Endpoint Guard Agent
- Mobile Shield Agent
- Correlation Agent
- Policy Agent
- Response Coordinator Agent
- Verification Agent
- Zeroth Guard Interface Agent (only user-facing)

---

## 5. Suggested 6-Week Execution Plan

### Week 1 - Definition + Integration Prep
- Finalize MVP scope and incident/action schemas
- Define policy matrix (allowed actions by risk level)
- Set up router/DNS integration path

### Week 2 - Ingest + Detection Foundation
- Implement telemetry ingestion
- Build subnet/device inventory baseline
- Implement first high-signal detection rule

### Week 3 - Decision + Execution Loop
- Add risk scoring and policy checks
- Implement guarded action runner
- Implement verification and audit logging

### Week 4 - Mobile Visibility
- Build incident read APIs
- Configure APNs event pipeline
- Implement iOS incident feed and incident detail screens

### Week 5 - Mobile Response Control
- Implement iOS automatic action status flow
- Add emergency override path with biometric gate
- Stream action state updates to app

### Week 6 - Hardening + Validation
- Reliability and failure-mode testing
- False-positive tuning
- Home-lab adversarial simulation and validation

---

## 6. Lean Team Composition

- 1 backend/security engineer (agents, policy, action loop)
- 1 iOS engineer (mobile app, auth, push, action UX)
- 1 part-time infra/security operator (network integration, testing, hardening)

---

## 7. Major MVP Risks and Mitigations

### 7.1 Unsafe Automation Risk
- **Risk:** over-aggressive actions disrupt normal home traffic
- **Mitigation:** constrained action catalog + policy checks + verification + reversible defaults

### 7.2 Detection Noise / False Positives
- **Risk:** too many noisy alerts reduce trust
- **Mitigation:** start with high-confidence rules and tune thresholds weekly

### 7.3 Integration Fragility (Router/DNS Vendors)
- **Risk:** control APIs vary by device ecosystem
- **Mitigation:** implement adapter abstraction and target one primary gateway first

### 7.4 Mobile Security Exposure
- **Risk:** weak session handling or unsafe emergency overrides
- **Mitigation:** short-lived tokens, Keychain storage, step-up auth, signed nonce requests

---

## 8. Definition of Done (MVP)

MVP is complete when all are true:

- System detects at least 3 prioritized home-subnet threat scenarios
- At least 3 response actions execute via policy-authorized automatic guarded path
- Every action includes verification status and audit entry
- iPhone app receives alerts and displays actionable incident context
- Emergency override actions require user confirmation with secure auth controls
- End-to-end loop works reliably on **Mac mini** local deployment (after proving the vertical slice on the **development laptop** where applicable)

---

## 9. Immediate Next Step

Create implementation backlog (epics + tickets) directly from:
- `docs/architecture.md`
- `docs/agents.md`
- `docs/hardware.md`
- `docs/ios-app-spec.md`

Start with one vertical slice and ship it before expanding agent coverage.
