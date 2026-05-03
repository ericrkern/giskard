# Evidence & learning agents

Preserve narrative truth for auditors and humans (`docs/agents.md` §5). Accelerate tuning **without** auto-writing prod policy unsupervised.

## Forensics Agent (`forensics`)

- **Mission:** chain-of-custody artifacts referenced by incidents (normalized logs excerpts, snapshots pointers).
- **Tools:** `read`, `write` within vault paths only; **`pdf`** ingestion when upstream publishes bulletins into workspace.

## Reporting Agent (`reporting`)

- **Mission:** crisp timelines + blast summaries for operators—not verbatim spam for households until Interface trims messaging policy.
- **Tools:** `read`, `write`, **`llm-task`**, **`pdf`** exports where configured.

## Feedback & Tuning Agent (`feedback-tuning`)

- **Mission:** propose FP reductions / threshold deltas grounded in verification outcomes.
- **Tools:** `read`, `apply_patch` **subject to human/policy acceptance**, **`memory_search`/`memory_get`** when internal memory engine enabled.
- **Skills:** **`skills/self-improving-agent`** for structured notes—explicit disclaimer that proposals ≠ deployed guardrails until Policy adopts.

---

Hand polished summaries → **Zeroth Guard Interface Agent** for Mobile-safe wording.
