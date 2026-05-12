## Phase 0 — MVP scope and acceptance criteria (architecture freeze)

This document is the **Phase 0 deliverable** referenced by `docs/implementation_plan.md` §Phase 0. It freezes the first end-to-end MVP slice so later work can be implemented and tested without redefining goals mid-stream.

### MVP threat scenarios (first three)

- **Suspicious DNS / C2 beaconing** from a subnet device
- **Lateral scanning** within the LAN (east-west discovery + suspicious port sweeps)
- **Credential abuse behavior** (burst login failures, stuffing-style patterns, abnormal session churn)

### MVP automated actions (first three)

Actions must flow through **Observe → Evaluate → Simulate → Execute → Verify → Record** and be authorized by policy.

- **Block domain / IP at DNS or gateway**
- **Isolate / quarantine** a device into a restricted segment (VLAN/SSID/quarantine policy)
- **Force re-auth / revoke session or token** (only when an IdP integration exists and the policy tier allows)

### Definition of Done (first vertical slice)

The MVP “vertical slice” is complete when all items below are true for **at least one** threat scenario (start with DNS/C2):

- **Detect**
  - Ingest a real signal from the protected subnet (not synthetic-only)
  - Emit an `agent_finding` that maps to an ATT&CK technique (best-effort) and includes `trace_id`
- **Correlate**
  - Create/attach to an `incident` with stable identifiers (`incident_id`, `asset_id`, `subnet_id`)
- **Decide**
  - Produce a deterministic `policy_disposition` (`alert` / `ask` / `act`) with justification fields
- **Act**
  - Execute one policy-authorized action through a guarded command pipeline
  - Capture evidence refs before/after enforcement
- **Verify**
  - Confirm the expected state change (e.g. outbound traffic stopped; device isolated; session invalidated)
  - Mark `verification.status` as `verified|partial|failed`
- **Record**
  - Persist an audit timeline with immutable ordering and `trace_id` linkage
- **Report**
  - Surface the incident + action + verification outcome to **Zeroth Guard Mobile** (customer-facing plane)

### Non-goals for Phase 0 / MVP freeze

- No requirement for a full SOC-grade web dashboard (operator UI may exist, but is not customer-facing).
- No requirement for broad cloud integrations; local-first behavior is acceptable and preferred.

