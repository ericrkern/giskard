---
name: n8n-workflow-automation
description: Chat- or event-driven automation against a local n8n instance for enrichment playbooks and operator glue (optional).
metadata: {"openclaw": {}}
---

# n8n workflow automation

## Use in Zeroth Guard

- Trigger **multi-step automations** (notify, enrich IOCs, open tickets) from agent findings while keeping **policy decisions** in Zeroth Guard.
- Fits **local-first** deployments where n8n runs on the protected subnet (e.g. Ubuntu prototype host).

## Install

Registry listing (verify slug on site): [ClawHub — n8n workflow automation](https://clawhub.ai/KOwl64/n8n-workflow-automation).

```bash
openclaw skills install KOwl64/n8n-workflow-automation
```

If the slug differs on ClawHub, use the exact command shown on the skill page after confirming **Benign** / acceptable scan status.

## Notes

- Do not grant n8n workflows privileges that **isolate hosts**, **change firewall rules**, or **revoke sessions** unless those actions flow through Zeroth Guard’s guarded execution path.
