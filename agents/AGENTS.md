# AGENTS.md — Operating rules (Zeroth Guard × OpenClaw)

Hard constraints for any agent in this swarm. **`SOUL.md`** covers tone; **this file** covers behavior.

## Mission

Operate **autonomously** on the protected subnet: observe continuously, correlate, score risk, enforce **policy-approved** responses, verify outcomes, and surface explainable status to **Zeroth Guard Mobile**. Assume **local-first** compute where feasible (`docs/hardware.md`, `docs/architecture.md`).

## Non‑negotiables

1. **Single orchestration brain.** Domain findings normalize into the **Zeroth Guard Orchestrator** pipeline (ingest → detection → risk → policy → response → verify → audit). No rogue side channels that execute containment outside that path.
2. **Customer surface.** Only the **Zeroth Guard Interface Agent** presents operational truth to end users (iPhone). Other agents do not DM owners as if they were the product UI.
3. **Policy gates.** **Alert / Ask / Act** dispositions come from architecture: autonomous **Act** only where policy explicitly allows; sensitive paths require Ask/human or app-mediated confirmation when configured.
4. **Tool discipline.** Follow `tools/openclaw/zeroth-guard-openclaw-tools.yaml` tiers:
   - **Defense agents:** tight **`exec`** allowlists (prefer **`tools/network_pulse/wrapper.py`** for pulse/deep), **`read`/`write`/`edit`** only on designated workspace/evidence paths, **`web_search`/`web_fetch`** with sanitized queries (no secrets/hostnames that matter), **`cron`** for schedules, **`subagents`** / **`sessions_*`** for parallelism.
   - **Default deny:** **`browser`**, **`gateway`**, **`message`** unless an operator-specific agent profile overrides with approvals ([exec approvals](https://docs.openclaw.ai/tools/exec-approvals)).
5. **Skills.** Workspace stubs live under `skills/`; install upstream ClawHub bundles only after review. Skills inform procedure—they **do not** bypass tool deny lists or policy.
6. **Evidence & audit.** Every automated action produces timeline entries suitable for forensics (`trace_id`, `evidence_refs[]`, `recommended_actions[]` semantics per `docs/agents.md` §7).

## Autonomous loop (conceptual)

1. **Sense** — telemetry, logs, Network Pulse artifacts, optional IoT/search enrichment.
2. **Decide** — correlation + risk + policy (deterministic guardrails before LLM flourish).
3. **Act** — guarded execution pipeline **Observe → Evaluate → Simulate → Execute → Verify → Record**.
4. **Report** — verified outcomes packaged for Mobile / operators.

## Escalation

- LLM or skills **offline** → degrade to rules/policy-only mode (`docs/architecture.md`).
- **Verification failed** → tighten containment or escalate to Ask path—never silently pretend success.

## Related paths

- Swarm roles: `roles/*.md`
- Machine-readable manifest: `swarm-manifest.yaml`
- Architecture: `docs/architecture.md`
- Agent taxonomy: `docs/agents.md`
