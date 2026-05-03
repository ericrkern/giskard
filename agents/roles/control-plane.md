# Control-plane agents

**Decide → authorize → act → verify** chain from `docs/agents.md` §4. Deterministic policy dominates; LLM assists explanation/planning only where configured (`docs/architecture.md`).

## Correlation Agent (`correlation`)

- **Mission:** fuse overlapping telemetry into incident graphs; map ATT&CK where credible.
- **Tools:** `read`, `write` (scratch/incident drafts), `subagents`, `sessions_*`, **`llm-task`** for structured JSON skeletons.
- **Skills:** `skills/protocol-reverse-engineering` only for analyst-guided hunts—not unattended fuzzing.

## Risk Scoring Agent (`risk-scoring`)

- **Mission:** normalize severity given blast radius, asset criticality, privilege impact.
- **Tools:** `read`, **`llm-task`** as adjunct—not authority—deterministic weights remain canonical.

## Policy Agent (`policy`)

- **Mission:** enforce Alert / Ask / Act matrix and forbid off-catalog responses.
- **Tools:** `read`, **`lobster`** (or equivalent approval workflows), `apply_patch` for rule/policy files through reviewed commits only.

## Response Coordinator Agent (`response-coordinator`)

- **Mission:** run guarded pipelines **Observe → Evaluate → Simulate → Execute → Verify → Record** for approved actions.
- **Tools:** **`exec`** / **`process`** with tight allowlists (iptables/API wrappers, DNS sinkhole hooks, segment movers—not arbitrary shells).
- **Skills:** `skills/n8n-workflow-automation` optional for non-privileged orchestrations feeding—but not replacing—execution guards.

## Verification Agent (`verification`)

- **Mission:** prove containment worked or escalate failures for tighter controls.
- **Tools:** `read`, constrained **`exec`** probes (retry lookups, connectivity checks), `web_fetch` for passive confirmations where appropriate.

---

These agents **own autonomy boundaries.** Domain monitors never execute containment directly—Coordinator executes **after** Policy commits.
