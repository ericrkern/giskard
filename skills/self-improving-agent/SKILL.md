---
name: self-improving-agent
description: Structured logging of errors, preferences, and learnings into operator-maintained memory for iterative tuning (optional).
metadata: {"openclaw": {}}
---

# Self-improving agent pattern

## Use in Zeroth Guard

- Reinforces the **feedback loop** in `docs/architecture.md`: false positives, playbook tweaks, operator preferences—**without** letting unreviewed text become executable policy.
- Use for **documentation-of-record** style memory; production rule changes still require explicit policy updates and audit.

## Install

Registry listing: [ClawHub — self-improving-agent](https://clawhub.ai/pskoett/self-improving-agent).

```bash
openclaw skills install pskoett/self-improving-agent
```

## Notes

- Scope stored learnings to non-secret operational hints; never persist credentials or raw PII.
