---
name: composio
description: Optional umbrella integrations for GitHub, Slack, Gmail, ticketing, and hundreds of SaaS APIs without bespoke auth per connector (Composio ecosystem).
metadata: {"openclaw": {}}
---

# Composio (recommended integration bridge)

## Use in Zeroth Guard

- Wire **alert fan-out**, **ticket creation**, **GitOps**, or **SOAR-like** steps while keeping enforcement logic in the Zeroth Guard orchestrator.
- Prefer **least privilege** API keys and narrow connector allowlists; skills must not bypass policy or speak directly to end users (iPhone remains the customer surface).

## Install (review upstream first)

- Browse / verify on [ClawHub](https://clawhub.ai/) with `openclaw skills search composio`.
- Typical upstream layout: [ComposioHQ/skills](https://github.com/ComposioHQ/skills); follow current registry install command shown on the skill page after security scan review.

```bash
openclaw skills search composio
openclaw skills install <slug-from-registry>
```

## Notes

- Third-party skills execute with whatever credentials you configure—audit before production ([OpenClaw skills security](https://docs.openclaw.ai/tools/skills)).
