## Phase 0 — Baseline architecture decisions (frozen defaults)

This document captures the “default answers” from `docs/implementation_plan.md` §Phase 0.3 so implementation can proceed without reopening fundamental choices repeatedly.

### Realtime delivery

- **Primary:** Server-Sent Events (SSE) from the control node API to the iOS app for realtime incident/action status.
- **Fallback:** Polling endpoints for degraded networks.
- **Optional later:** WebSocket if bidirectional streaming becomes a hard requirement.

### Data stores and retention (MVP defaults)

- **Event store:** Postgres (incidents, findings, actions, verification, audit timeline)
- **Evidence store:** filesystem-backed artifact store on the control node (later: encrypted object store)
- **Retention (MVP):**
  - incidents/audit: 30–90 days configurable
  - evidence artifacts: 7–30 days configurable (longer when a case is pinned)

### Process isolation and privilege tiers

- **Tier A (critical):** orchestrator + policy + response + verification services
  - least privilege; explicit `exec` allowlists only via wrappers
- **Tier B (sensors/tools):** ingest collectors, Network Pulse, other deterministic adapters
  - bounded runtime, timeouts, rate limits
- **Tier C (optional reasoning):** local LLM runtime (e.g. Ollama)
  - strictly advisory; no direct execution; must not be in the enforcement loop without policy gates

### iOS distribution (MVP)

- **TestFlight** for early field testing
- Plan for App Store later; MDM distribution is optional and not required for MVP

### OpenClaw on the control computer (defaults)

- **Runtime host:** single in-subnet control computer (Mac mini reference; Ubuntu laptop for bring-up per `docs/hardware.md`).
- **Repo layout:** this monorepo is present on the host so `agents/`, `tools/`, `skills/`, and `external/network-scan-agent` are available.
- **Tools policy defaults:** use `tools/openclaw/zeroth-guard-openclaw-tools.yaml` as the reference list; autonomous defense agents deny-by-default `browser`, `gateway`, and `message` unless an operator profile is explicitly configured.
- **Skills scope (MVP):**
  - allowed: `skills/home-assistant`, `skills/exa-search`, `skills/composio` (after operator review)
  - caution/optional: `skills/n8n-workflow-automation`
  - operator-only/high risk: `skills/protocol-reverse-engineering`

### Network Pulse deployment (defaults)

- Network Pulse uses `tools/network_pulse/wrapper.py` to run the Git submodule at `external/network-scan-agent`.
- Prefer scheduled `pulse` runs; reserve `deep` for on-demand investigations or scheduled low-frequency depth (see `docs/architecture.md`).

