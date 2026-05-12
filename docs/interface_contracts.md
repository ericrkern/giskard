## Phase 0 — Interface contracts (schemas)

This document defines the **minimum shared contracts** for OpenClaw-hosted Zeroth Guard agents so findings, incidents, actions, verification, and audit events can be correlated reliably.

### Where the machine-readable schemas live

JSON Schemas are stored under `schemas/`:

- `schemas/finding.schema.json`
- `schemas/incident.schema.json`
- `schemas/action_request.schema.json`
- `schemas/action_result.schema.json`
- `schemas/verification.schema.json`
- `schemas/audit_event.schema.json`

### Required correlation fields (shared)

All schemas include, at minimum:

- `incident_id`
- `asset_id`
- `subnet_id`
- `trace_id`

### Core event types

- **Finding (`agent_finding`)**: produced by domain agents; describes what was observed, why it matters, and recommended actions.
- **Incident (`incident`)**: orchestrator object that aggregates findings and drives policy disposition.
- **Action request / result (`action_request`, `action_result`)**: policy-authorized actions and their execution outcomes.
- **Verification (`verification`)**: post-action outcome confirmation (verified / partial / failed) with evidence.
- **Audit event (`audit_event`)**: append-only timeline events linking everything by `trace_id`.

### Schema versioning expectations

- **Schema files** contain `schema_version` and a stable `type`.
- Backward-incompatible changes require a `schema_version` bump and a migration note in this doc.

