# ADA iOS App Specification

## 1. Purpose

`ADA Mobile` is the iOS companion app for Giskard's Active Defense Agent platform.  
It provides secure mobile visibility into incidents and enables policy-bounded response actions for authorized operators.

Primary outcomes:
- receive real-time incident alerts
- understand risk quickly
- execute approved response actions safely
- verify outcomes with full audit history

---

## 2. Product Scope

### In Scope (MVP)
- Secure authentication (OIDC + MFA)
- Incident feed with severity/status filters
- Incident detail timeline and evidence summary
- Action approval + execution flow for policy-approved actions
- Real-time push notifications (APNs)
- Device inventory view for home subnet assets (computers, phones, tablets, IoT)

### Out of Scope (MVP)
- Full policy editing from mobile
- Deep packet/evidence raw-data browsing
- Custom automation playbook authoring
- Offline action execution without server validation

---

## 3. User Roles

- **Owner/Admin**: full incident visibility, full action authority (within policy)
- **Responder**: incident visibility + limited action scope
- **Viewer**: read-only incident visibility

All actions are server-authorized and logged.

---

## 4. Core User Flows

### 4.1 Login + Enrollment
1. User opens app
2. Starts OIDC login
3. Completes MFA challenge
4. App exchanges auth code for short-lived session tokens
5. Device is bound to account and trust state is registered

### 4.2 Incident Notification to Action
1. APNs push arrives (minimal metadata only)
2. User opens incident detail
3. App fetches signed incident payload + recommended actions
4. User confirms action (biometric/PIN gate)
5. Backend runs policy validation
6. Response executes if approved
7. Verification and audit status stream back to app

### 4.3 Subnet/Mobile Containment
1. App displays compromised mobile/tablet/computer in subnet
2. Responder chooses allowed action (quarantine segment, block domain, revoke token)
3. App submits signed action request with justification
4. Backend executes through ADA command pipeline
5. App shows verification outcome and rollback guidance if needed

---

## 5. Screen Architecture

## 5.1 Auth Screens
- Splash / bootstrap check
- Sign-in entry
- MFA challenge
- Device trust enrollment

## 5.2 Main App Tabs
- **Incidents**
- **Devices**
- **Actions**
- **Audit**
- **Settings**

## 5.3 Incident Feed Screen
- List by severity (Critical/High/Medium/Low)
- Filters: status, asset type, subnet, ATT&CK tactic
- Quick indicators: active containment, awaiting approval, verified

## 5.4 Incident Detail Screen
- Header: severity, confidence, affected assets, active state
- Timeline: detection -> decision -> action -> verification
- Evidence summary cards (not raw full dumps)
- Recommended actions with policy rationale

## 5.5 Action Confirmation Screen
- Action description and expected impact
- Preconditions and rollback notes
- Biometric confirmation
- Submit + live status

## 5.6 Devices Screen
- Subnet inventory grouped by type:
  - computers
  - phones
  - tablets
  - IoT/unmanaged
- Trust posture and risk flags
- Device-level containment options (policy-scoped)

## 5.7 Audit Screen
- Chronological action log
- Actor (human or autonomous)
- Policy decision reason
- Verification result and timestamps

---

## 6. Technical Architecture (iOS)

### 6.1 Stack
- Swift + SwiftUI
- MVVM + feature modules
- URLSession + async/await
- Combine/AsyncStream for live updates

### 6.2 Suggested Module Layout
- `AppCore` (bootstrap, routing, config)
- `AuthFeature`
- `IncidentFeature`
- `DeviceFeature`
- `ActionFeature`
- `AuditFeature`
- `SettingsFeature`
- `SharedUI`
- `Networking`
- `Security`

### 6.3 State Management
- Feature-level view models
- Central session store (auth state, role, trust)
- Immutable incident/action models from backend contracts

---

## 7. API Contract (Initial)

Base path: `/mobile`

### Auth
- `POST /auth/exchange`
  - input: auth code + PKCE verifier
  - output: access token, refresh token, expiry, role claims

- `POST /auth/refresh`
  - input: refresh token
  - output: rotated access token/refresh token

### Incidents
- `GET /incidents?severity=&status=&cursor=`
  - output: paginated incident summaries

- `GET /incidents/{incidentId}`
  - output: incident detail, timeline, recommended actions, evidence summary

### Devices
- `GET /devices?subnetId=`
  - output: device list with type, trust posture, risk state

- `GET /devices/{deviceId}`
  - output: device profile, recent detections, allowed actions

### Actions
- `POST /actions`
  - input:
    - `incidentId`
    - `targetType` (host/device/subnet/identity)
    - `targetId`
    - `actionType`
    - `justification`
    - `clientNonce`
  - output: `actionId`, `state` (queued/running/verified/failed), `auditRef`

- `GET /actions/{actionId}`
  - output: status, verification details, rollback recommendation (if any)

### Audit
- `GET /audit?cursor=`
  - output: action/event timeline entries

### Realtime
- `GET /stream` (SSE) or `GET /ws` (WebSocket upgrade)
  - events:
    - `incident.created`
    - `incident.updated`
    - `action.state_changed`
    - `verification.completed`

---

## 8. Security Requirements

### 8.1 On-Device Security
- Store tokens in Keychain only
- Use Secure Enclave-backed keys when available
- No sensitive payload caching beyond necessity
- Redact sensitive fields from logs

### 8.2 Transport Security
- TLS 1.2+
- Certificate pinning
- Optional mTLS for high-trust deployments

### 8.3 Action Authorization
- All actions validated server-side against policy
- Step-up auth (biometric + re-auth) for high-impact actions
- Signed requests with nonce + short TTL to prevent replay

### 8.4 App Integrity
- Basic jailbreak/root signal checks
- Runtime tamper checks where feasible
- Device trust score included in action policy decisions

---

## 9. Notification Design (APNs)

### Push payload policy
- Do not include sensitive evidence data in push body
- Include only:
  - incident ID
  - severity
  - action-required flag

### Notification categories
- `incident_critical`
- `incident_high`
- `action_required`
- `verification_complete`

---

## 10. Data Models (Initial)

### IncidentSummary
- `id`
- `title`
- `severity`
- `status`
- `createdAt`
- `assetCount`
- `requiresAction`

### IncidentDetail
- `id`
- `severity`
- `confidence`
- `affectedAssets[]`
- `timeline[]`
- `recommendedActions[]`
- `evidenceSummary[]`

### Device
- `id`
- `name`
- `type` (`computer` | `phone` | `tablet` | `iot`)
- `ip`
- `subnetId`
- `trustState`
- `riskState`
- `allowedActions[]`

### ActionRequest
- `incidentId`
- `targetType`
- `targetId`
- `actionType`
- `justification`
- `clientNonce`

### ActionResult
- `actionId`
- `state`
- `policyDecision`
- `verificationStatus`
- `auditRef`

---

## 11. UX Rules

- Prioritize clarity over density in incident detail
- Always show blast-radius preview before action confirm
- Prevent one-tap destructive actions
- Show explicit verification status after execution
- Keep color semantics consistent with risk levels

---

## 12. Observability & QA

### App Telemetry
- Auth success/failure rates
- Push delivery open rates
- Action submit-to-verify latency
- Client errors by feature/module

### Testing Strategy
- Unit tests for view models and API clients
- Snapshot/UI tests for key screens
- Integration tests against staging API
- Security tests for token storage and pinning behavior

---

## 13. MVP Milestones

### Milestone 1 - Foundations
- Auth flow + token lifecycle
- Incident feed + detail read path
- APNs registration and routing

### Milestone 2 - Response
- Action confirmation flow
- Server-validated action submit
- Live action state updates

### Milestone 3 - Subnet + Mobile Coverage
- Device inventory (computers/phones/tablets)
- Device-targeted containment options
- Audit timeline and verification detail

### Milestone 4 - Hardening
- Biometric step-up for critical actions
- Cert pinning + improved integrity checks
- Performance and reliability tuning

---

## 14. Open Decisions

- SSE vs WebSocket as default realtime channel
- App Store distribution vs enterprise MDM only
- Minimum iOS version target
- Role granularity for delegated responders
- Whether mobile can initiate rollback actions directly

---

## 15. Definition of Done (MVP)

- User can securely sign in with MFA
- User receives and opens live incident alerts
- User can review incident context and execute authorized action
- Backend policy validation is enforced for every action
- Verification and audit records are visible in app
- Subnet devices (including phones/tablets/computers) are represented and actionable by role
